using System.Collections;
using System.Collections.Generic;
using EasyButtons;
using UnityEngine;

[ExecuteAlways]
public class CausticsVolume : MonoBehaviour
{
    [SerializeField] private Material causticsMaterial;

    void Start()
    {
    }

    void Update()
    {
        var sunMatrix = RenderSettings.sun.transform.localToWorldMatrix;
        causticsMaterial.SetMatrix("_MainLightMatrix", sunMatrix);
        causticsMaterial.SetVector("_MainLightDirection", -1 * RenderSettings.sun.transform.forward);
    }
}
