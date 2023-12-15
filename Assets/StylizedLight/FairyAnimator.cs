using UnityEngine;
using UnityEngine.Splines;

namespace StylizedLight
{
    public class FairyAnimator : MonoBehaviour
    {
        [SerializeField] private SplineContainer _spline;
        [SerializeField] private float _speed = 1f;
        [SerializeField] private float _minSpeed = 0.2f;
        [SerializeField] private float _maxAcc = 0.2f;
        [SerializeField] private float _accMult = 2f;

        [SerializeField] private float _noiseFreq = 1;
        [SerializeField] private float _noiseAmp = 1;
        
        private float _time;
        private float _momentum;
        
        private void Update()
        {
            if (Input.GetKey(KeyCode.A))
                return;
            
            var acc = _spline.EvaluateAcceleration(_time);
            var clampedAcc = Mathf.Clamp(_accMult * acc.y, -1 * _maxAcc, _maxAcc);
            Debug.Log(clampedAcc);
            _momentum += -1 * clampedAcc * Time.deltaTime;
            
            _time += Time.deltaTime * Mathf.Max(_momentum * _speed, _minSpeed);
            
            _spline.Evaluate(_time % 1, out var position, out var tangent, out var upVector);

            var noise = GetNoise(_time);
            
            transform.position = (Vector3) position + noise;
            transform.rotation = Quaternion.LookRotation(tangent, upVector);
        }

        private Vector3 GetNoise(float time)
        {
            var v = time * _noiseFreq;
            var vec = new Vector3(Mathf.PerlinNoise1D(v), Mathf.PerlinNoise1D(v + 153 * Mathf.PI), Mathf.PerlinNoise1D(v + 201 * Mathf.PI));
            return _noiseAmp * vec;
        }
    }
}