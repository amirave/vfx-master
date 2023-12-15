using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeMovement : MonoBehaviour
{
    public float frequency = 1f;
    public float amplitude = 1f;
    public Vector3 axis = Vector3.up;
    
    private Vector3 _intialPos;

    void Start()
    {
        _intialPos = transform.position;
    }

    void Update()
    {
        transform.position = _intialPos + axis * (amplitude * Mathf.Sin(frequency * Time.time));
    }
}
