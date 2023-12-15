using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SuzanneSpawner : MonoBehaviour
{
    [SerializeField] private Transform _suzannePrefab;
    [SerializeField] private float _launchForce = 5f;
    [SerializeField] private Vector3 _launchTorque;
    [SerializeField] private float _launchRate = 1;
    private float _lastLaunch;

    void Start()
    {
        _lastLaunch = Time.time + 0.1f;
    }

    void Update()
    {
        if (Time.time - _lastLaunch > _launchRate)
        {
            _lastLaunch = Time.time;
            var suzanne = Instantiate(_suzannePrefab, transform.position, Quaternion.identity);
            suzanne.gameObject.SetActive(true);
            suzanne.transform.LookAt(Camera.main.transform.position);
            suzanne.GetComponent<Rigidbody>().AddForce(transform.forward * _launchForce, ForceMode.Impulse);
            Vector3 rand = new Vector3(Random.Range(-_launchTorque.x, _launchTorque.x), Random.Range(-_launchTorque.y, _launchTorque.y),
                Random.Range(-_launchTorque.z, _launchTorque.z));
            suzanne.GetComponent<Rigidbody>().AddTorque(rand, ForceMode.Impulse);
            
        }
    }
}
