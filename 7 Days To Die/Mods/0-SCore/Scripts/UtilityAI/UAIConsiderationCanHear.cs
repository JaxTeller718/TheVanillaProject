﻿using System.Collections.Generic;
using System.Globalization;
using UnityEngine;

namespace UAI
{
    public class UAIConsiderationCanNotHearTarget : UAIConsiderationCanHearTarget
    {
        public override float GetScore(Context _context, object target)
        {
            var targetEntity = UAIUtils.ConvertToEntityAlive(target);
            if (targetEntity != null && targetEntity.IsDead())
                return 0f;

            return (base.GetScore(_context, target) == 1f) ? 0f : 1f;
        }
    }

    public class UAIConsiderationCanHearTarget : UAIConsiderationBase
    {
        public override float GetScore(Context _context, object target)
        {
            var targetEntity = UAIUtils.ConvertToEntityAlive(target) as EntityPlayer;
            if (targetEntity == null)
                return 0f;

            // Taken from PlayerStealth's Tick()
            float distance = targetEntity.GetDistance(_context.Self);

            // figure out the noise volume and distance, using the EAI system settings for zombies.
            float num11 = targetEntity.Stealth.noiseVolume * (1f + EAIManager.CalcSenseScale() * _context.Self.aiManager.feralSense);
            num11 /= distance * 0.6f + 0.4f;
            bool flag = true;
            if (_context.Self.noisePlayer)
                flag = (num11 > _context.Self.noisePlayerVolume);

            // if we can still hear them, set the target
            if (flag)
            {
                _context.Self.noisePlayer = targetEntity;
                _context.Self.noisePlayerDistance = distance;
                _context.Self.noisePlayerVolume = num11;
            }

            // If we have a noisy player, and we can hear them.
            if (_context.Self.noisePlayer)
            {
                if (_context.Self.noisePlayerVolume >= _context.Self.noiseWake)
                {
                    _context.Self.SetInvestigatePosition(_context.Self.noisePlayer.position, 1200, true);
                    return 1;
                }
            }

            return 0f;
        }
    }
}