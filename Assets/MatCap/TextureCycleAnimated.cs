using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TextureCycleAnimated : MonoBehaviour
{
    [SerializeField] private GameObject[] _targets;
    [SerializeField] private RawImage _preview;
    [SerializeField] private Texture[] _textures;
    [SerializeField] private string _textureKeyword = "_MainTex";
    [SerializeField] private string _secondTextureKeyword = "_Texture2";
    [SerializeField] private string _fadeKeyword = "_Fade";
    [SerializeField] private float _fadeSpeed = 1f;

    private int index = 0;
    private MaterialPropertyBlock propertyBlock;

    void Start()
    {
        foreach (var target in _targets)
        {
            propertyBlock = new MaterialPropertyBlock();
            //target.GetComponent<Renderer>().GetPropertyBlock(propertyBlock);
            propertyBlock.SetTexture(_textureKeyword, _textures[index]);
            //target.GetComponent<Renderer>().SetPropertyBlock(propertyBlock);
            _preview.texture = _textures[index];
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            index++;
            foreach (var target in _targets)
            {
                // propertyBlock.SetTexture(_textureKeyword, _textures[index % _textures.Length]);
                // target.GetComponent<Renderer>().SetPropertyBlock(propertyBlock);
                // _preview.texture = _textures[index % _textures.Length];
                // target.GetComponent<Renderer>().SetPropertyBlock(propertyBlock);
                
            }
            StartCoroutine(FadeTexture(_textures[index % _textures.Length],
                _textures[(index + 1) % _textures.Length], _fadeSpeed));
        }
    }

    IEnumerator FadeTexture(Texture texture1, Texture texture2, float fadeSpeed)
    {
        float startTime = Time.time;
        // propertyBlock.SetTexture(_textureKeyword, texture1);
        // propertyBlock.SetTexture(_secondTextureKeyword, texture2);
        _targets[0].GetComponent<Renderer>().sharedMaterial.SetTexture(_textureKeyword, texture1);
        _targets[0].GetComponent<Renderer>().sharedMaterial.SetTexture(_secondTextureKeyword, texture2);
        
        while (startTime + fadeSpeed > Time.time)
        {
            float t = (Time.time - startTime) / fadeSpeed;
            Debug.Log("Fading " + t);
            foreach (var target in _targets)
            {
                target.GetComponent<Renderer>().sharedMaterial.SetFloat(_fadeKeyword, t);
            }
            // propertyBlock.SetFloat(_fadeKeyword, t);
            
            yield return null;
        }
        _preview.texture = texture1;
    }
}