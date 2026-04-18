using UnityEngine;
using UnityEngine.EventSystems;

namespace UI
{
    public class MouseoverSelect : MonoBehaviour, IPointerEnterHandler
    {
        public void OnPointerEnter(PointerEventData eventData)
        {
            EventSystem.current.SetSelectedGameObject(gameObject);
        }
    }
}
