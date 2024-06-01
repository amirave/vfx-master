using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class MoonShell : MonoBehaviour
{
    public Renderer[] _renderers;

    public float _noiseReveal = 0;
    public float _noiseFeather = 0;

    public float _noiseOffset = 0;
    // [ColorUsage(true, true, 0, 1, 0.125f, 3)]
    public Color _glow = Color.white;
    public float _glowIntensity = 1;
    
    void Awake()
    {
        
    }

    void Update()
    {
        foreach (var renderer in _renderers)
        {
            if (Application.isPlaying)
            {
                
            }
            else
            {
                var mat = new Material(renderer.sharedMaterial);
                var glowFactor = Mathf.Pow(2, _glowIntensity);
                var finalColor = new Color(_glow.r * glowFactor, _glow.g * glowFactor, _glow.b * glowFactor, _glow.a);
                
                mat.SetFloat("_NoiseReveal", _noiseReveal);
                mat.SetFloat("_NoiseFeather", _noiseFeather);
                mat.SetFloat("_NoiseOffset", _noiseOffset);
                mat.SetColor("_Glow", finalColor);
                
                renderer.sharedMaterial = mat;
            }
        }
    }
}
