using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletProjectile : MonoBehaviour {

    [Header("Bullet Properties")]
    // speed of the bullet
    public float speed;
    // velocity of the bullet (dir)
    public Vector3 velocity;

    // how many steps should be predicted per frame
    [Header("Accuracy")]
    [Range(1, 300)]
    public float stepsPerFrame;

    [Header("Environment Properties")]
    public Vector3 windDir = Vector3.zero;
    public float windIntensity;

    [Header("Hittable objects")]
    public LayerMask hitLayer;

    void Start () {
        if (speed < 0) speed = 1f;
        if (velocity == Vector3.zero)
            velocity = transform.forward * speed;
        else
            velocity *= speed;	
	}

    bool isMoving = false;
	void Update () {
        isMoving = true;
        Vector3 current = transform.position;
        /*         
         steps per frame means how many times we want this bullet to check hitting per frame
         lets assume steps per frame is 1 than it is really inaccurate because the arch might end up
         being like a line

         if the bullet moves too fast and the distance between the hit object and the bullet is too long
         then the bullet might not be able to predict hit accurately
         */
        float stepSize = 1 / stepsPerFrame;
        for (float step = 0; step < 1; step += stepSize)
        {
            velocity += (Physics.gravity + windDir.normalized * windIntensity) * stepSize * Time.deltaTime;
            Vector3 dest = current + velocity * stepSize * Time.deltaTime;

            // do the raycast
            Ray ray = new Ray(current, (dest - current).normalized);
            RaycastHit hit;
            if(Physics.Raycast(ray, out hit, (dest - current).magnitude, hitLayer)){
                if (hit.collider.gameObject == this.gameObject)
                    return;
                Debug.Log("hit: " + hit.collider.gameObject.name);
            }
            // finish raycast

            current = dest;
        }
        transform.position = current;
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Vector3 origin = transform.position;
        // predict one hundred times per frame
        float stepSize = 0.01f;
        Vector3 temporaryVelocity;

        if (!isMoving)
        {
            // when the game is not start, preview
            if (velocity != Vector3.zero)
                temporaryVelocity = velocity * speed;
            else
                temporaryVelocity = transform.forward * speed;
        }else
        {
            // if the game starts though, just make it equal to velocity
            temporaryVelocity = velocity;
        }   

        for (float step = 0; step < 1; step+= stepSize)
        {
            temporaryVelocity += (Physics.gravity + windDir.normalized * windIntensity) * stepSize;
            Vector3 dest = origin + temporaryVelocity * stepSize;
            Gizmos.DrawLine(origin, dest);
            origin = dest;
        }
    }
}
