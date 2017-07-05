using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MeshDrawer : MonoBehaviour
{

    public Mesh meshToDraw;
    public Material distortMaterial;

    public Transform distortTarget;

    Vector3 distortTargetPos
    {
        get { if (distortTarget)
                return distortTarget.position;

            return transform.position;
        }
    }

    // Use this for initialization
    void Start()
    {

    }


    // Update is called once per frame
    void Update()
    {

        distortMaterial.SetVector("_DisplaceTarget", transform.InverseTransformPoint(distortTarget.position));

        //Shader.SetGlobalVector("_DisplaceTarget", transform.InverseTransformPoint(distortTargetPos));

        Graphics.DrawMesh(meshToDraw, transform.position, transform.rotation, distortMaterial, 0);
    }
}
