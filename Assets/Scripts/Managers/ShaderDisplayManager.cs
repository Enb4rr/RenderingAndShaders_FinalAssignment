using System;
using System.Collections.Generic;
using ScriptableObjects;
using TMPro;
using UnityEngine;

namespace Managers
{
    public class ShaderDisplayManager : BaseManager<ShaderDisplayManager>
    {
        [field: Header("Shaders to Display")]
        [field: SerializeField] public List<ShaderData> shadersData = new List<ShaderData>();

        [Header("UI Components")] 
        [SerializeField] private TMP_Text shaderNameText;
        [SerializeField] private TMP_Text shaderDescriptionText;

        [Header("Components")] 
        [SerializeField] private GameObject prefabsParent;

        private int displayIndex = 0;
        private int previousDisplayedIndex = -1;
        private Dictionary<ShaderId, GameObject> lookup = new();

        private void Awake()
        {
            BuildLookup();
            AssignToScriptableObjects();
        }

        private void Start()
        {
            shaderNameText.text = "";
            shaderDescriptionText.text = "";
            
            UpdateDisplayedShader();
        }

        public void LoadNextShader()
        {
            previousDisplayedIndex = displayIndex;
            displayIndex++;
            if (displayIndex >= shadersData.Count) displayIndex = 0;
            
            UpdateDisplayedShader();
        }

        public void LoadPreviousShader()
        {
            previousDisplayedIndex = displayIndex;
            displayIndex--;
            if (displayIndex < 0) displayIndex = shadersData.Count - 1;
            
            UpdateDisplayedShader();
        }
        
        void BuildLookup()
        {
            var children = prefabsParent.GetComponentsInChildren<Transform>();
            foreach (Transform child in children)
            {
                var idComponent = child.GetComponent<PrefabIdentifier>();
                if (idComponent != null)
                {
                    lookup[idComponent.identifier] = child.gameObject;
                }
            }
        }

        void AssignToScriptableObjects()
        {
            foreach (var shaderData in shadersData)
            {
                if (lookup.TryGetValue(shaderData.shaderId, out GameObject obj))
                {
                    shaderData.SetReference(obj);
                }
            }
        }

        private void UpdateDisplayedShader()
        {
            if (previousDisplayedIndex != -1 && shadersData[previousDisplayedIndex] != null)
            {
                shadersData[previousDisplayedIndex].shaderObject.SetActive(false);
                shaderNameText.text = "";
                shaderDescriptionText.text = "";
            }
                

            if (shadersData[displayIndex] != null)
            {
                shadersData[displayIndex].shaderObject.SetActive(true);
                shaderNameText.text = shadersData[displayIndex].shaderName;
                shaderDescriptionText.text = shadersData[displayIndex].shaderDescription;
            }
        }
    }
}
