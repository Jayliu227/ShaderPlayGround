using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class ParticleInstancer : MonoBehaviour {

    // define the data structure for a particle
    struct Particle
    {
        public Vector3 position;
        public Vector3 velocity;
        public Color color;
        public bool isActive;
        public float duration;
        public float scale;
    }

    // public refenrences
    public ComputeShader computeShader;
    public Material material;                    // the material with which these particles get rendered

    /*
        three compute shaders:
        a. stores all the particle data
        b. manage the index of all data and act like a LIFO queue to determine which particles to emit
        c. stores the count information of the pool buffer (can also be used as an argbuffer) 
    */
    ComputeBuffer particleBuffer;
    ComputeBuffer particlePoolBuffer;
    ComputeBuffer counterBuffer;
    int[] particleCounts; // the data that is passed to counterBuffer

    // variables of the particle
    float lifeTime = 3f;
    float gravity = 5f;
    float maxVelocity = 5f;

    // several variables that control the particle
    int particleMax = 960000;
    int emitMax = 256;
    int particleNum;
    int emitNum;

    // these two don't have any effect yet because they need to be processed in GS
    float minScale = 0.1f;
    float maxScale = 2f;

    const int THREAD_NUM = 16;

    // index for different compute shader kernels
    int initKernel;
    int emitKernel;
    int updateKernel;

    /// <summary>
    /// Initialize all the varaiables, assign buffers to shaders and initialize particles
    /// </summary>
    void Initialize()
    {
        particleNum = (particleMax / THREAD_NUM) * THREAD_NUM;
        emitNum = (emitMax / THREAD_NUM) * THREAD_NUM;

        particleBuffer = new ComputeBuffer(particleNum, Marshal.SizeOf(typeof(Particle)), ComputeBufferType.Default);

        particlePoolBuffer = new ComputeBuffer(particleNum, Marshal.SizeOf(typeof(Particle)), ComputeBufferType.Append);
        particlePoolBuffer.SetCounterValue(0);

        counterBuffer = new ComputeBuffer(4, sizeof(int), ComputeBufferType.IndirectArguments);
        particleCounts = new int[] { 0, 1, 0, 0 };  // num of vertices, num of instances, start and end offset
        counterBuffer.SetData(particleCounts);

        initKernel   = computeShader.FindKernel("Init");
        emitKernel   = computeShader.FindKernel("Emit");
        updateKernel = computeShader.FindKernel("Update");

        InitParticle();
    }

    /// <summary>
    /// Initialize single particle
    /// </summary>
    void InitParticle()
    {
        computeShader.SetBuffer(initKernel, "_Particles", particleBuffer);
        computeShader.SetBuffer(initKernel, "_DeadList", particlePoolBuffer);
        
        computeShader.Dispatch(initKernel, particleNum/ THREAD_NUM, 1, 1);   
    }

    void EmitParticle(Vector3 mousePosition)
    {
        counterBuffer.SetData(particleCounts);
        ComputeBuffer.CopyCount(particlePoolBuffer, counterBuffer, 0);
        counterBuffer.GetData(particleCounts);

        int particlePoolNum = particleCounts[0];
        if (particlePoolNum < emitNum)
        {
            return;
        }else
        {
            computeShader.SetVector("_EmitPosition", mousePosition);
            computeShader.SetFloat("_MaxVelocity", maxVelocity);
            computeShader.SetFloat("_LifeTime", lifeTime);
            computeShader.SetFloat("_MinScale", minScale);
            computeShader.SetFloat("_MaxScale", maxScale);
            computeShader.SetFloat("_Time", Time.time);
            computeShader.SetBuffer(emitKernel, "_Particles", particleBuffer);
            computeShader.SetBuffer(emitKernel, "_ParticlePool", particlePoolBuffer);

            computeShader.Dispatch(emitKernel, emitNum / THREAD_NUM, 1, 1);
        }
    }
    
    void UpdateParticle()
    {
        computeShader.SetFloat("_DeltaTime", Time.deltaTime);
        computeShader.SetFloat("_LifeTime", lifeTime);
        computeShader.SetFloat("_Gravity", gravity);

        computeShader.SetBuffer(updateKernel, "_Particles", particleBuffer);
        computeShader.SetBuffer(updateKernel, "_DeadList", particlePoolBuffer);

        computeShader.Dispatch(updateKernel, particleMax / THREAD_NUM, 1, 1);
    }

	void Start () {
        Initialize();
	}
	
	void Update () {
        if (Input.GetMouseButton(0))
        {
            Vector3 mousePos = Input.mousePosition;
            mousePos.z = 10f;
            Vector3 pos = Camera.main.ScreenToWorldPoint(mousePos);
            EmitParticle(pos);
        }
        UpdateParticle();
	}

    void OnRenderObject()
    {
        if(material != null)
        {
            material.SetBuffer("_Particles", particleBuffer);
            material.SetPass(0);

            Graphics.DrawProcedural(MeshTopology.Points, particleNum, 1);
        }
    }

    private void OnDestroy()
    {
        foreach (ComputeBuffer b in new[] { particleBuffer, counterBuffer, particlePoolBuffer })
            if (b != null)
                b.Release();
    }
}
