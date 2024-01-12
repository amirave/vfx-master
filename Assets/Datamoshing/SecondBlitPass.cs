using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Datamoshing
{
    public class SecondBlitPass : ScriptableRenderPass
    {
        private Material _material;
        private RTHandle m_cameraDepthTarget;
        private RTHandle m_cameraColorTarget;
        private RTHandle m_prevTarget;
        private RenderTextureDescriptor m_Descriptor;

        public SecondBlitPass(Material material)
        {
            _material = material;
            renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (renderingData.cameraData.cameraType != CameraType.Game)
                return;
            CommandBuffer cmd = CommandBufferPool.Get();
            
            m_prevTarget ??= RTHandles.Alloc(m_Descriptor); 
            using (new ProfilingScope(cmd, new ProfilingSampler("SecondBlitPass")))
            {
                // _material.SetTexture("_Prev2", m_cameraColorTarget);
                // Blitter.BlitCameraTexture(cmd, m_cameraColorTarget, m_prevTarget, _material, 0);
                cmd.SetGlobalTexture("_Prev2", m_prevTarget);
                // RTHandles.Release(m_prevTarget);
                Blitter.BlitCameraTexture(cmd, m_cameraColorTarget, m_cameraColorTarget, _material, 0);
                // m_prevTarget = RTHandles.Alloc(m_cameraColorTarget);
            }
            
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            m_Descriptor = renderingData.cameraData.cameraTargetDescriptor;
        }

        public void SetTarget(RTHandle cameraColorTarget, RTHandle cameraDepthTarget)
        {
            m_cameraColorTarget = cameraColorTarget;
            m_cameraDepthTarget = cameraDepthTarget;
        }
    }
}