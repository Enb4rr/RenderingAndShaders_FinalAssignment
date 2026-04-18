using NaughtyAttributes;
using UnityEngine;

namespace ScriptableObjects
{
    [CreateAssetMenu(fileName = "ShaderData", menuName = "ScriptableObjects/ShaderData")]
    public class ShaderData : ScriptableObject
    {
        public string shaderName;
        public ShaderId shaderId;
        [TextArea(3, 6)] public string shaderDescription;
        
        [HorizontalLine]
        
        public GameObject shaderObject;
        
        public void SetReference(GameObject obj)
        {
            shaderObject = obj;
        }
    }

    public enum ShaderId
    {
        Vertex,
        Fragment,
        PostProcess,
        Item,
        Environment
    }
}
