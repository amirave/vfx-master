using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderPropertyAnimator : MonoBehaviour
{

    public float _intensity;
    [SerializeField] private Material _material;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        _material.SetFloat("_ShapeTexIntensity", _intensity);
    }
}
