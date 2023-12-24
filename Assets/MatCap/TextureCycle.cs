using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TextureCycle : MonoBehaviour
{
    [SerializeField] private GameObject[] _targets;
    [SerializeField] private RawImage _preview;
    [SerializeField] private Texture[] _textures;
    [SerializeField] private string _textureKeyword = "_MainTex";

    private int index = 0;
    private MaterialPropertyBlock propertyBlock;

    void Start()
    {
        foreach (var target in _targets)
        {
            propertyBlock = new MaterialPropertyBlock();
            target.GetComponent<Renderer>().GetPropertyBlock(propertyBlock);
            propertyBlock.SetTexture(_textureKeyword, _textures[index]);
            target.GetComponent<Renderer>().SetPropertyBlock(propertyBlock);
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
                propertyBlock.SetTexture(_textureKeyword, _textures[index % _textures.Length]);
                target.GetComponent<Renderer>().SetPropertyBlock(propertyBlock);
                _preview.texture = _textures[index % _textures.Length];
            }
        }
    }
}
