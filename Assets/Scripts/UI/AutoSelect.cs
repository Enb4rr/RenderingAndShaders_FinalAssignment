using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace UI
{
    public class AutoSelect : MonoBehaviour
    {
        private void Start()
        {
            if (TryGetComponent(out Selectable button))
            {
                EventSystem.current.SetSelectedGameObject(null);
                button.Select();
            }
        }

        private void OnEnable()
        {
            if (TryGetComponent(out Selectable button))
            {
                EventSystem.current.SetSelectedGameObject(null);
                button.Select();
            }
        }
    }
}
