using UnityEngine;
using System.Collections.Generic;

public class FishBoidController : MonoBehaviour
{
    [Header("Fish Spawning")]
    public GameObject fishPrefab;
    public int numberOfFish = 50;
    public Vector3 spawnBounds = new Vector3(10f, 5f, 10f);
    
    [Header("Fish Size")]
    public float minSize = 0.8f;
    public float maxSize = 1.2f;

    [Header("Interest Point")]
    public Transform interestPoint;

    [Header("Boid Parameters")]
    [Range(0f, 10f)] public float cohesionWeight = 1f;
    [Range(0f, 10f)] public float separationWeight = 1f;
    [Range(0f, 10f)] public float alignmentWeight = 1f;
    [Range(0f, 10f)] public float interestPointWeight = 1f;

    [Header("Movement Parameters")]
    [Range(0f, 10f)] public float maxSpeed = 5f;
    [Range(0f, 10f)] public float maxSteerForce = 3f;
    [Range(0f, 10f)] public float neighborRadius = 5f;
    [Range(0f, 1f)] public float velocityDamping = 0.95f;
    [Range(0f, 1f)] public float rotationDamping = 0.9f;

    [Header("Separation Curve")]
    public AnimationCurve separationCurve = AnimationCurve.EaseInOut(0, 1, 1, 0);

    private List<FishData> fishList = new List<FishData>();

    private class FishData
    {
        public GameObject GameObject;
        public Vector3 Velocity;
        public Quaternion TargetRotation;
    }

    private void Start()
    {
        SpawnFish();
    }

    private void SpawnFish()
    {
        for (int i = 0; i < numberOfFish; i++)
        {
            Vector3 randomPosition = new Vector3(
                Random.Range(-spawnBounds.x, spawnBounds.x),
                Random.Range(-spawnBounds.y, spawnBounds.y),
                Random.Range(-spawnBounds.z, spawnBounds.z)
            );

            randomPosition += interestPoint.position;

            GameObject fish = Instantiate(fishPrefab, transform.position + randomPosition, Quaternion.identity);
            fish.transform.SetParent(transform);

            float randomSize = Random.Range(minSize, maxSize);
            fish.transform.localScale = Vector3.one * randomSize;

            fishList.Add(new FishData { 
                GameObject = fish, 
                Velocity = Random.insideUnitSphere * maxSpeed,
                TargetRotation = Random.rotation
            });
        }
    }

    private void Update()
    {
        foreach (FishData fish in fishList)
        {
            Vector3 acceleration = CalculateBoidAcceleration(fish);
            UpdateFishPosition(fish, acceleration);
        }
    }

    private Vector3 CalculateBoidAcceleration(FishData fish)
    {
        Vector3 cohesion = CalculateCohesion(fish) * cohesionWeight;
        Vector3 separation = CalculateSeparation(fish) * separationWeight;
        Vector3 alignment = CalculateAlignment(fish) * alignmentWeight;
        Vector3 interestPointForce = CalculateInterestPointForce(fish) * interestPointWeight;

        return cohesion + separation + alignment + interestPointForce;
    }

    private Vector3 CalculateCohesion(FishData fish)
    {
        Vector3 centerOfMass = Vector3.zero;
        int count = 0;

        foreach (FishData neighbor in fishList)
        {
            if (neighbor != fish && IsInNeighborhood(fish, neighbor))
            {
                centerOfMass += neighbor.GameObject.transform.position;
                count++;
            }
        }

        if (count > 0)
        {
            centerOfMass /= count;
            return SteerTowards(fish, centerOfMass);
        }

        return Vector3.zero;
    }

    private Vector3 CalculateSeparation(FishData fish)
    {
        Vector3 separationForce = Vector3.zero;

        foreach (FishData neighbor in fishList)
        {
            if (neighbor != fish && IsInNeighborhood(fish, neighbor))
            {
                Vector3 awayFromNeighbor = fish.GameObject.transform.position - neighbor.GameObject.transform.position;
                float distance = awayFromNeighbor.magnitude;
                float separationFactor = separationCurve.Evaluate(distance / neighborRadius);
                separationForce += awayFromNeighbor.normalized * separationFactor / distance;
            }
        }

        return SteerTowards(fish, fish.GameObject.transform.position + separationForce);
    }

    private Vector3 CalculateAlignment(FishData fish)
    {
        Vector3 averageVelocity = Vector3.zero;
        int count = 0;

        foreach (FishData neighbor in fishList)
        {
            if (neighbor != fish && IsInNeighborhood(fish, neighbor))
            {
                averageVelocity += neighbor.Velocity;
                count++;
            }
        }

        if (count > 0)
        {
            averageVelocity /= count;
            return SteerTowards(fish, fish.GameObject.transform.position + averageVelocity);
        }

        return Vector3.zero;
    }

    private Vector3 CalculateInterestPointForce(FishData fish)
    {
        return SteerTowards(fish, interestPoint.position);
    }

    private bool IsInNeighborhood(FishData fish, FishData neighbor)
    {
        return Vector3.Distance(fish.GameObject.transform.position, neighbor.GameObject.transform.position) <= neighborRadius;
    }

    private Vector3 SteerTowards(FishData fish, Vector3 target)
    {
        Vector3 desired = (target - fish.GameObject.transform.position).normalized * maxSpeed;
        return Vector3.ClampMagnitude(desired - fish.Velocity, maxSteerForce);
    }

    private void UpdateFishPosition(FishData fish, Vector3 acceleration)
    {
        fish.Velocity += acceleration * Time.deltaTime;
        fish.Velocity = Vector3.ClampMagnitude(fish.Velocity, maxSpeed);
        fish.Velocity *= velocityDamping;
        
        fish.GameObject.transform.position += fish.Velocity * Time.deltaTime;
        
        if (fish.Velocity != Vector3.zero)
        {
            fish.TargetRotation = Quaternion.LookRotation(fish.Velocity);
            fish.GameObject.transform.rotation = Quaternion.Slerp(fish.GameObject.transform.rotation, fish.TargetRotation, 1 - rotationDamping);
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireCube(transform.position, spawnBounds * 2);
    }
}