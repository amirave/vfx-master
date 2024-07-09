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
        [SerializeField] private float _startOffset = 0;

        [SerializeField] private float _noiseFreq = 1;
        [SerializeField] private float _noiseAmp = 1;
        
        private float _time;
        private float _momentum;
        
        private void Awake()
        {
            _time = _startOffset;
            UpdateTransform();
        }
        
        private void Update()
        {
            if (Input.GetKey(KeyCode.A))
                return;

            _time += Time.deltaTime * _momentum * _speed;
            UpdateTransform();
        }

        private void UpdateTransform()
        {
            var acc = _spline.EvaluateAcceleration(_time);
            _momentum = Mathf.Clamp(-1 * acc.y, _minSpeed, _maxAcc);
            
            _spline.Evaluate(_time % 1, out var position, out var tangent, out var upVector);

            var noise = GetNoise(_time);

            transform.position = (Vector3)position + noise;
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