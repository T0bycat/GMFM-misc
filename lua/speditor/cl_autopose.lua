--[[
SPeditor — auto pose (b0.2.6-misc.1, after Cascadeur's AutoPosing, as a plain solver: no neural net).

With Auto pose on (View → Auto pose), a hand pulled by IK takes the body along once the arm
would have to stretch: the chest bends and turns toward the hand, then the hips, then the body
steps over; the feet stay planted (View → IK: keep the feet planted), the other hand too when
the hands are planted. Within the arm's comfortable reach only the arm moves, as with plain IK.

It works on the physics bodies of a ragdoll, found by the bone tree, so it is not tied to the
Valve skeleton: the torso is every body between the dragged arm's shoulder and the root.

  AP.Begin(ent, hand, shoulder, elbow) -> state (state.items are the gizmo drag's items) or nil
  AP.Solve(state, target)              the pose for the hand at target (fills it.p1 / it.a1)
  C.AutoPoseOn() / C.SetAutoPose(on)
  gmfm_autopose_follow 0..1            how much the body follows (0 — plain IK)
]]
SPeditor = SPeditor or {}
SPeditor.AutoPose = SPeditor.AutoPose or {}
local AP = SPeditor.AutoPose
local C  = SPeditor.Client

local cvAuto   = CreateClientConVar("gmfm_autopose", "0", true, false, "Auto pose: a dragged hand takes the body along (0/1)", 0, 1)
local cvFollow = CreateClientConVar("gmfm_autopose_follow", "1", true, false, "Auto pose: how much the body follows the hand (0..1)", 0, 1)
function C.AutoPoseOn() return cvAuto:GetBool() end
-- (b0.2.6-misc.1) Auto pose works through IK (a hand's chain): turning it on turns IK on too
function C.SetAutoPose(on)
	RunConsoleCommand("gmfm_autopose", on and "1" or "0")
	if on and C.SetIK and not (C.gizmo and C.gizmo.ik) then C.SetIK(true) end
end
-- what the viewport shows: Auto pose that will act (IK or the rig is on)
function C.AutoPoseActive() return cvAuto:GetBool() and C.gizmo and (C.gizmo.ik or (C.RigOn and C.RigOn())) or false end

-- the share of the arm's full length where the body starts to help (a straight arm looks stiff)
local COMFORT = 0.88
-- how far each body of the torso may turn in one drag, degrees: the one nearest the shoulder
-- (the chest), the ones between, the root (the hips)
local MAX_NEAR, MAX_MID, MAX_ROOT = 40, 30, 25
-- how far the root may step toward the hand, in lengths of a leg: along the floor, down (a
-- crouch: the knees bend), up
local MAX_STEP, MAX_CROUCH, MAX_RISE = 0.35, 0.6, 0.1
local ITERATIONS = 8
-- the share of the arm's length where the hand starts to ease in (soft IK)
local SOFT = 0.1
-- (b0.2.6-misc.1) how much of its turn in the world the head keeps while the chest bends under it (the
-- eyes stay on what they looked at, as a person reaching does; 0 — it turns with the chest)
local HEAD_KEEP = 0.6

local FOOT = { "foot", "ankle", "hoof" }
local HAND = { "hand", "wrist", "paw" }
local function named(ent, bone, list)
	local n = string.lower(ent:GetBoneName(bone) or "")
	for _, p in ipairs(list) do
		if string.find(n, p, 1, true) then return true end
	end
	return false
end
function AP.IsHand(ent, bone) return not named(ent, bone, FOOT) and named(ent, bone, HAND) end

local function physParent(ent, bone)
	local b, guard = ent:GetBoneParent(bone), 0
	while b and b >= 0 and guard < 256 do
		if C.PhysIndexOfBone(ent, b) then return b end
		b = ent:GetBoneParent(b)
		guard = guard + 1
	end
end

local function isBelow(ent, bone, ancestor)
	local b, guard = bone, 0
	while b and b >= 0 and guard < 256 do
		if b == ancestor then return true end
		b = ent:GetBoneParent(b)
		guard = guard + 1
	end
	return false
end

local function rotateVec(v, k, deg)
	local th = math.rad(deg)
	local c, s = math.cos(th), math.sin(th)
	return v * c + k:Cross(v) * s + k * (k:Dot(v) * (1 - c))
end

-- the bodies in list turn by deg around axis k through pivot
local function turnAround(list, pivot, k, deg)
	for _, it in ipairs(list) do
		it.p1 = pivot + rotateVec(it.p1 - pivot, k, deg)
		it.a1 = rotateVec(it.a1:Forward(), k, deg):AngleEx(rotateVec(it.a1:Up(), k, deg))
	end
end

-- the way a two-link limb bends (root, mid, end places): the middle's offset from the root-end
-- line, as a direction; nil when the limb is straight
local function bendOf(r, m, e)
	local d = (e - r):GetNormalized()
	local off = (m - r) - d * (m - r):Dot(d)
	if off:LengthSqr() < 1e-6 then return nil end
	return off:GetNormalized()
end

-- the middle of a two-link limb of lengths l1, l2 from root toward target, bent toward pole (a
-- direction; as SPeditor.IK.Solve, but the bend comes from the given direction, not from where
-- the middle happens to be: a knee carried round by the hips can end up behind the hip-foot line,
-- and an elbow on the shoulder-hand line has no side at all)
local function solveLimb(root, l1, l2, target, pole)
	local toT = target - root
	local dist = toT:Length()
	if dist < 1e-3 then return nil end
	local dir = toT / dist
	local d = math.min(math.max(dist, math.abs(l1 - l2) * 1.0005 + 0.01), (l1 + l2) * 0.9995)
	local cosA = math.Clamp((l1 * l1 + d * d - l2 * l2) / (2 * l1 * d), -1, 1)
	local sinA = math.sqrt(1 - cosA * cosA)
	local side = pole - dir * pole:Dot(dir)
	if side:LengthSqr() < 1e-6 then
		local ref = (math.abs(dir.z) < 0.9) and Vector(0, 0, 1) or Vector(1, 0, 0)
		side = ref - dir * ref:Dot(dir)
	end
	return root + dir * (l1 * cosA) + side:GetNormalized() * (l1 * sinA), root + dir * d
end

-- a two-link chain (root, mid, end items) bent so that the end is at endPos with the turn
-- endAng; what hangs below the end goes along rigidly (as cl_gizmo.lua's solveChain). pole: the
-- bend direction (nil — the middle's own side, as plain IK)
local function solveChain(r, m, e, tail, endPos, endAng, pole)
	local IK = SPeditor.IK
	local midNew, endNew
	if pole then
		midNew, endNew = solveLimb(r.p1, r.p0:Distance(m.p0), m.p0:Distance(e.p0), endPos, pole)
	end
	if not midNew then midNew, endNew = IK.Solve(r.p1, m.p1, e.p1, endPos) end
	r.a1 = IK.RotateAngle(r.a1, m.p1 - r.p1, midNew - r.p1)
	m.a1 = IK.RotateAngle(m.a1, e.p1 - m.p1, endNew - midNew)
	m.p1 = midNew
	for _, t in ipairs(tail) do
		local lp, la = WorldToLocal(t.p1, t.a1, e.p1, e.a1)
		t.p1, t.a1 = LocalToWorld(lp, la, endNew, endAng)
	end
	e.p1, e.a1 = endNew, endAng
end

-- the other limbs of the body that stay where they are: { root, mid, end, tail }
local function plantedLimbs(ent, byBone, skipEnd, feet, hands)
	local out = {}
	for b, it in pairs(byBone) do
		if b ~= skipEnd and ((feet and named(ent, b, FOOT)) or (hands and AP.IsHand(ent, b))) then
			local mid = physParent(ent, b)
			local root = mid and physParent(ent, mid)
			if root and byBone[mid] and byBone[root] then
				local tail = {}
				for b2, it2 in pairs(byBone) do
					if b2 ~= b and isBelow(ent, b2, b) then tail[#tail + 1] = it2 end
				end
				-- a planted limb keeps bending the way it did (the knee points where it pointed);
				-- straight at the start: the way the root faces
				local pole = bendOf(byBone[root].p0, byBone[mid].p0, it.p0) or byBone[root].a0:Forward()
				out[#out + 1] = { byBone[root], byBone[mid], it, tail, pole = pole }
			end
		end
	end
	return out
end

function AP.Begin(ent, hand, shoulder, elbow)
	if not (IsValid(ent) and C.IsRagdoll(ent)) then return nil end
	local items, byBone = {}, {}
	for b = 0, ent:GetBoneCount() - 1 do
		local pi = C.PhysIndexOfBone(ent, b)
		local p, a
		if pi then p, a = C.GetBoneWorld(ent, b) end
		if p and a then
			local it = { physIdx = pi, bone = b, p0 = p, a0 = a, p1 = p, a1 = a }
			items[#items + 1] = it
			byBone[b] = it
		end
	end
	local S, F, H = byBone[shoulder], byBone[elbow], byBone[hand]
	if not (S and F and H) then return nil end
	-- the torso: from the body the shoulder hangs on up to the root
	local torso, j = {}, physParent(ent, shoulder)
	while j and byBone[j] do
		torso[#torso + 1] = { it = byBone[j], bone = j }
		j = physParent(ent, j)
	end
	if #torso == 0 then return nil end
	for i, t in ipairs(torso) do
		t.max = (i == #torso) and MAX_ROOT or (i == 1 and MAX_NEAR or MAX_MID)
		t.list = {}
		for b, it in pairs(byBone) do
			if isBelow(ent, b, t.bone) then t.list[#t.list + 1] = it end
		end
	end
	-- the head (a body named head on the torso, not on the arm): it keeps its turn, with what is below it
	local head
	for b, it in pairs(byBone) do
		if not head and named(ent, b, { "head" }) and isBelow(ent, b, torso[#torso].bone)
			and not isBelow(ent, b, shoulder) and not isBelow(ent, shoulder, b) then
			head = { it = it, list = {} }
			for b2, it2 in pairs(byBone) do
				if isBelow(ent, b2, b) then head.list[#head.list + 1] = it2 end
			end
		end
	end
	-- what hangs below the hand (rare: a weapon body) goes with it
	local below = {}
	for b, it in pairs(byBone) do
		if b ~= hand and isBelow(ent, b, hand) then below[#below + 1] = it end
	end
	-- the elbow's way of bending, in the shoulder's frame: it turns with the chest
	local bend = bendOf(S.p0, F.p0, H.p0)
	local elbowPole = bend and WorldToLocal(bend, angle_zero, vector_origin, S.a0) or nil
	local st = { ent = ent, items = items, S = S, F = F, H = H, torso = torso, below = below, elbowPole = elbowPole, head = head,
		l1 = S.p0:Distance(F.p0), l2 = F.p0:Distance(H.p0),
		planted = plantedLimbs(ent, byBone, hand, C.gizmo.ikFeet, C.gizmo.ikHands) }
	-- a leg's length (the step of the root): thigh to foot of the first planted foot
	st.leg = 40
	for _, l in ipairs(st.planted) do
		if named(ent, l[3].bone, FOOT) then st.leg = l[1].p0:Distance(l[2].p0) + l[2].p0:Distance(l[3].p0) break end
	end
	-- the arm's comfortable reach, but never less than the hand already is (no jump at the start)
	st.reach = math.max((st.l1 + st.l2) * COMFORT, S.p0:Distance(H.p0))
	return st
end

function AP.Solve(st, target)
	for _, it in ipairs(st.items) do it.p1, it.a1 = it.p0, it.a0 end
	local follow = math.Clamp(cvFollow:GetFloat(), 0, 1)
	local S = st.S
	if follow > 0 then
		local used = {}
		-- the torso bends toward the hand, the body nearest the shoulder first (cyclic coordinate
		-- descent with each body taking half of what is left, up to its own limit)
		for _ = 1, ITERATIONS do
			local toT = target - S.p1
			local dist = toT:Length()
			if dist - st.reach < 0.05 or dist < 1e-3 then break end
			for i, t in ipairs(st.torso) do
				local want = target - toT:GetNormalized() * st.reach      -- where the shoulder should be
				local pivot = t.it.p1
				local from, to = S.p1 - pivot, want - pivot
				local axis = from:Cross(to)
				local s = axis:Length()
				if s > 1e-6 and from:LengthSqr() > 1e-4 then
					local deg = math.deg(math.atan2(s, from:Dot(to))) * 0.5 * follow
					local room = t.max * follow - (used[i] or 0)
					deg = math.min(deg, math.max(room, 0))
					if deg > 1e-3 then
						turnAround(t.list, pivot, axis / s, deg)
						used[i] = (used[i] or 0) + deg
					end
				end
				toT = target - S.p1
			end
		end
		-- the head turns back toward where it looked (round its own joint: the neck keeps its length)
		local hd = st.head
		if hd and HEAD_KEEP > 0 then
			local a0, a1 = hd.it.a0, hd.it.a1
			local f0, u0, f1, u1 = a0:Forward(), a0:Up(), a1:Forward(), a1:Up()
			local l0, l1 = u0:Cross(f0), u1:Cross(f1)
			-- the turn from now back to the start, as an axis and an angle
			local ax = f1:Cross(f0) + l1:Cross(l0) + u1:Cross(u0)
			local tr = f1:Dot(f0) + l1:Dot(l0) + u1:Dot(u0)
			local s2 = ax:Length()
			if s2 > 1e-6 then
				local deg = math.deg(math.atan2(s2, tr - 1)) * HEAD_KEEP * follow
				turnAround(hd.list, hd.it.p1, ax / s2, deg)
			end
		end
		-- still out of reach: the whole body steps toward the hand (the feet stay, the legs bend):
		-- along the floor, down into a crouch, hardly up (the feet would have to leave the floor)
		local toT = target - S.p1
		local gap = toT:Length() - st.reach
		if gap > 0 then
			local shift = toT:GetNormalized() * gap * follow
			local flat = Vector(shift.x, shift.y, 0)
			local fl = flat:Length()
			local maxFlat = st.leg * MAX_STEP * follow
			if fl > maxFlat then flat = flat * (maxFlat / fl) end
			local z = math.Clamp(shift.z, -st.leg * MAX_CROUCH * follow, st.leg * MAX_RISE * follow)
			shift = flat + Vector(0, 0, z)
			for _, it in ipairs(st.items) do it.p1 = it.p1 + shift end
		end
	end
	-- the planted feet and hands must stay within reach: the body is pulled back toward the one
	-- that is furthest out (a straight leg cannot follow the hips up)
	for _ = 1, 4 do
		local worst, dir
		for _, l in ipairs(st.planted) do
			-- never less than the limb is at the start: a standing leg is nearly straight already
			local len = math.max((l[1].p0:Distance(l[2].p0) + l[2].p0:Distance(l[3].p0)) * 0.995, l[1].p0:Distance(l[3].p0))
			local toE = l[3].p0 - l[1].p1
			local ex = toE:Length() - len
			if ex > 1e-3 and (not worst or ex > worst) then worst, dir = ex, toE:GetNormalized() end
		end
		if not worst then break end
		for _, it in ipairs(st.items) do it.p1 = it.p1 + dir * worst end
	end
	-- the planted feet (and hands) go back to where they were
	for _, l in ipairs(st.planted) do
		solveChain(l[1], l[2], l[3], l[4], l[3].p0, l[3].a0, l.pole)
	end
	-- the arm reaches the hand, which keeps its turn in the world (as plain IK)
	-- soft IK: in the last tenth of the arm's length the hand eases toward the target instead of
	-- snapping the elbow straight (near a straight arm the elbow swings fast for a little pull)
	local L = st.l1 + st.l2
	local toT = target - S.p1
	local dist = toT:Length()
	local soft = L * SOFT
	local ds = math.max(L - soft, st.S.p0:Distance(st.H.p0))
	if dist > ds and dist > 1e-3 and L - ds > 1e-3 then
		local room = L - ds
		target = S.p1 + toT * ((ds + room * (1 - math.exp(-(dist - ds) / room))) / dist)
	end
	local pole = st.elbowPole and LocalToWorld(st.elbowPole, angle_zero, vector_origin, S.a1) or nil
	solveChain(S, st.F, st.H, st.below, target, st.H.a0, pole)
end
