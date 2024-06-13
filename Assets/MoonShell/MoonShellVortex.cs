using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

[ExecuteAlways]
public class MoonShellVortex : MonoBehaviour
{
    public Renderer[] _vortexRenderers;
    public MaterialPropertyBlock _vortexPropBlock;
    
    public Renderer _helixRenderer;
    public MaterialPropertyBlock _helixPropBlock;

    public float _vortexOpacity = 1;
    public float _vortexSpeed = 1;
    public float _helixOpacity = 1;
    
    void Awake()
    {
        _helixPropBlock = new MaterialPropertyBlock();
        _helixRenderer.SetPropertyBlock(_helixPropBlock);
    }

    void Update()
    {
        foreach (var renderer in _vortexRenderers)
        {
            if (Application.isPlaying)
            {
                renderer.material.SetFloat("_Opacity", _vortexOpacity);
                renderer.material.SetFloat("_Speed", _vortexSpeed);
            }
            else
            {
                var mat = new Material(renderer.sharedMaterial);

                mat.SetFloat("_Opacity", _vortexOpacity);
                mat.SetFloat("_VoronoiSpeed", _vortexSpeed);
                
                renderer.sharedMaterial = mat;
            }
        }
        
        if (Application.isPlaying)
        {
            _helixRenderer.material.SetFloat("_Opacity", _helixOpacity);
        }
        else
        {
            var mat = new Material(_helixRenderer.sharedMaterial);

            mat.SetFloat("_Opacity", _helixOpacity);
            
            _helixRenderer.sharedMaterial = mat;
        }
    }
}
