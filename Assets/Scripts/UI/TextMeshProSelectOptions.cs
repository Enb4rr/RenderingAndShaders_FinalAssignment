using System;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;

namespace UI
{
    [DefaultExecutionOrder(-1)]
    public class TextMeshProSelectOptions : MonoBehaviour, ISelectHandler, IDeselectHandler
    {
        [SerializeField] private TextMeshProUGUI text;
        [SerializeField] private TextOptions normalOptions;
        [SerializeField] private TextOptions selectedOptions;
        
        private void OnValidate()
        {
            if (text == null) text = GetComponentInChildren<TextMeshProUGUI>();
        }

        private void OnEnable()
        {
            OnDeselect(null);
        }

        public void OnSelect(BaseEventData eventData)
        {   
            text.color = selectedOptions.Color;
            text.fontStyle = selectedOptions.Style;
        }

        public void OnDeselect(BaseEventData eventData)
        {
            text.color = normalOptions.Color;
            text.fontStyle = normalOptions.Style;
        }
    }
}
