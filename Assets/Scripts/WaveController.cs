﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, RequireComponent(typeof(MeshDrawer))]
public class WaveController : MonoBehaviour {

    public Transform windSource;

    Vector3 windDirection
    {
        get { if (windSource)
                return new Vector3(windSource.forward.x,windSource.forward.z,0);
            else
                return new Vector3(0.5f, 0.5f, 0);
        }
    }

    [Range(0,1)]
    public float waveDirectionVariance = 45;
    
    [System.Serializable]
    public struct waveAttributes
    {
        public float amplitude;
        public float wavelength;
        public float speed;
        [Range(0,1)]
        public float steepness;
        public Transform direction;
        //need direction variance fear each wave that stays same
    }

    [SerializeField]
    public waveAttributes[] waves;

    int numberOfWaves;// { get { return waves.Length; } }

    float[] A = new float[10];
    float[] L = new float[10];
    float[] S = new float[10];
    float[] Q = new float[10];
    Vector4[] D = new Vector4[10];

    MeshDrawer meshDrawer;
    Material waveMaterial;

    void RepackWaveData()
    {
        numberOfWaves = 0;

        for (int i = 0; i < 10; ++i)
        {
            if (waves[i].amplitude <= 0) continue;

            numberOfWaves++;

            A[i] = waves[i].amplitude;
            L[i] = waves[i].wavelength;
            S[i] = waves[i].speed;
            Q[i] = waves[i].steepness;
            D[i] = GetWaveDirection(waves[i].direction);
        }
    }

    Vector4 GetWaveDirection(Transform dir)
    {
        if (!dir) return new Vector4(1,0,0,0);

        return new Vector4(dir.forward.x,dir.forward.z,0,0);
    }


    void InitShaderArrays(Material mat)
    {
        mat.SetFloatArray("_A", new float[10]);
        mat.SetFloatArray("_L", new float[10]);
        mat.SetFloatArray("_S", new float[10]);
        mat.SetFloatArray("_Q", new float[10]);
        mat.SetVectorArray("_D", new Vector4[10]);
    }

    void UpdateShaderArrays(Material mat)
    {
        mat.SetFloatArray("_A", A);
        mat.SetFloatArray("_L", L);
        mat.SetFloatArray("_S", S);
        mat.SetFloatArray("_Q", Q);
        mat.SetVectorArray("_D", D);
    }


    // Use this for initialization
    void OnEnable () {
        waves = new waveAttributes[10];
        
        meshDrawer = GetComponent<MeshDrawer>();
        waveMaterial = meshDrawer.distortMaterial;

        InitShaderArrays(waveMaterial);
	}
	
	// Update is called once per frame
	void Update () {
        RepackWaveData();
        UpdateShaderArrays(waveMaterial);
        waveMaterial.SetInt("_i", numberOfWaves);
        //waveMaterial.SetVector("D",windDirection);
	}

    
}
