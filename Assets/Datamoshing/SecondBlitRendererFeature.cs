using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Datamoshing
{
    public class SecondBlitRendererFeature : ScriptableRendererFeature
    {
        private SecondBlitPass m_customPass;
        [SerializeField] private Shader m_shader;
        
        private Material m_material;

        public override void Create()
        {
            m_material = CoreUtils.CreateEngineMaterial(m_shader);
            m_customPass = new SecondBlitPass(m_material);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(m_customPass);
        }

        public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
        {
            Camera.main.depthTextureMode |= (DepthTextureMode.MotionVectors | DepthTextureMode.Depth);

            if (renderingData.cameraData.cameraType == CameraType.Game)
            {
                var mask = ScriptableRenderPassInput.Color ^ ScriptableRenderPassInput.Depth ^ ScriptableRenderPassInput.Motion;
                m_customPass.ConfigureInput(mask);
                m_customPass.SetTarget(renderer.cameraColorTargetHandle, renderer.cameraDepthTargetHandle);
            }
        }

        protected override void Dispose(bool disposing)
        {
            CoreUtils.Destroy(m_material);
        }
    }
}