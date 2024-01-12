using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeCameraOrbit : MonoBehaviour
{
    [SerializeField] private float speed = 15f;
    [SerializeField] private bool useFixedUpdate = false;
    
    void Update()
    {
        if (!useFixedUpdate)
            transform.rotation *= Quaternion.AngleAxis(speed * Time.deltaTime, Vector3.up);
    }

    private void FixedUpdate()
    {
        if (useFixedUpdate) 
            transform.rotation *= Quaternion.AngleAxis(speed * Time.fixedDeltaTime, Vector3.up);
    }
}
