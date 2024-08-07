using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

[ExecuteAlways]
public class MoonShell : MonoBehaviour
{
    public Renderer[] _renderers;
    public MaterialPropertyBlock _propBlock;

    public float _noiseReveal = 0;
    public float _noiseFeather = 0;
    public float _noiseOpacity = 0;

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
        if (Input.GetKeyDown(KeyCode.Space))
        {
            GetComponent<PlayableDirector>().Stop();
            GetComponent<PlayableDirector>().Play();
        }
        
        var glowFactor = Mathf.Pow(2, _glowIntensity);
        var finalColor = new Color(_glow.r * glowFactor, _glow.g * glowFactor, _glow.b * glowFactor, _glow.a);

        foreach (var renderer in _renderers)
        {
            if (Application.isPlaying)
            {
                renderer.material.SetFloat("_NoiseReveal", _noiseReveal);
                renderer.material.SetFloat("_NoiseFeather", _noiseFeather);
                renderer.material.SetFloat("_NoiseOffset", _noiseOffset);
                renderer.material.SetFloat("_NoiseOpacity", _noiseOpacity);
                renderer.material.SetColor("_Glow", finalColor);
            }
            else
            {
                var mat = new Material(renderer.sharedMaterial);

                mat.SetFloat("_NoiseReveal", _noiseReveal);
                mat.SetFloat("_NoiseFeather", _noiseFeather);
                mat.SetFloat("_NoiseOffset", _noiseOffset);
                mat.SetFloat("_NoiseOpacity", _noiseOpacity);
                mat.SetColor("_Glow", finalColor);
                
                renderer.sharedMaterial = mat;
            }
        }
    }
}
