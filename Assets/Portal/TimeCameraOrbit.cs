using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeCameraOrbit : MonoBehaviour
{
    [SerializeField] private float speed = 15f;

    void Update()
    {
        transform.rotation *= Quaternion.AngleAxis(speed * Time.deltaTime, Vector3.up);
    }
}
