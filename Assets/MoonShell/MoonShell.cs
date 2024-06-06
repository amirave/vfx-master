using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class MoonShell : MonoBehaviour
{
    public Renderer[] _renderers;
    public MaterialPropertyBlock _propBlock;

    public float _noiseReveal = 0;
    public float _noiseFeather = 0;

    public float _noiseOffset = 0;
    // [ColorUsage(true, true, 0, 1, 0.125f, 3)]
    public Color _glow = Color.white;
    public float _glowIntensity = 1;
    
    void Awake()
    {
        _propBlock = new MaterialPropertyBlock();
        foreach (var renderer in _renderers)
        {
            renderer.SetPropertyBlock(_propBlock);
        }
    }

    void Update()
    {
        var glowFactor = Mathf.Pow(2, _glowIntensity);
        var finalColor = new Color(_glow.r * glowFactor, _glow.g * glowFactor, _glow.b * glowFactor, _glow.a);
                
        // _propBlock.SetFloat("_NoiseReveal", _noiseReveal);
        // _propBlock.SetFloat("_NoiseFeather", _noiseFeather);
        // _propBlock.SetFloat("_NoiseOffset", _noiseOffset);
        // _propBlock.SetColor("_Glow", finalColor);
        
        foreach (var renderer in _renderers)
        {
            if (Application.isPlaying)
            {
                renderer.material.SetFloat("_NoiseReveal", _noiseReveal);
                renderer.material.SetFloat("_NoiseFeather", _noiseFeather);
                renderer.material.SetFloat("_NoiseOffset", _noiseOffset);
                renderer.material.SetColor("_Glow", finalColor);
            }
            else
            {
                var mat = new Material(renderer.sharedMaterial);

                mat.SetFloat("_NoiseReveal", _noiseReveal);
                mat.SetFloat("_NoiseFeather", _noiseFeather);
                mat.SetFloat("_NoiseOffset", _noiseOffset);
                mat.SetColor("_Glow", finalColor);
                
                renderer.sharedMaterial = mat;
            }
        }
    }
}
