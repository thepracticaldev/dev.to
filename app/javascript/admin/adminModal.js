/**
 * A function to generate the HTML for a Crayons modal within the /admin/ space.
 *
 * @function adminModal
 * @param {Object} modalProps Properties of the Modal
 * @param {string} modalProps.title The title of the modal.
 * @param {string} modalProps.body The modal's content. May use HTML tags for styling.
 * @param {string} modalProps.leftBtnText The text for the modal's left button.
 * @param {string} modalProps.leftBtnAction The function that fires when left button is clicked.
 * @param {string} modalProps.rightBtnText The text for the modal's right button.
 * @param {string} modalProps.rightBtnAction The function that fires when right button is clicked.
 * @param {string} modalProps.leftBtnClasses Classes applied to left button.
 * @param {string} modalProps.rightBtnClasses Classes applied to right button.
 * @param {string} modalProps.customAttr A custom data attribute name. Will be apprended to the "data-" part.
 * @param {string} modalProps.customAttrValue The value of the custom attribute "customAttr".
 */
const adminModal = function ({
  title,
  body,
  leftBtnText,
  leftBtnAction,
  rightBtnText,
  rightBtnAction,
  leftBtnClasses,
  rightBtnClasses,
  customAttr = null,
  customAttrValue = null,
}) {
  return `
    <div class="crayons-modal crayons-modal--s">
      <div class="crayons-modal__box">
        <header class="crayons-modal__box__header">
          <p class="fw-bold fs-l">${title}</p>
          <button type="button" class="crayons-btn crayons-btn--icon crayons-btn--ghost" data-action="click->config#closeAdminModal">
            <svg width="24" height="24" viewBox="0 0 24 24" class="crayons-icon" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 10.586l4.95-4.95 1.414 1.414-4.95 4.95 4.95 4.95-1.414 1.414-4.95-4.95-4.95 4.95-1.414-1.414 4.95-4.95-4.95-4.95L7.05 5.636l4.95 4.95z" />
            </svg>
          </button>
        </header>
        <div class="crayons-modal__box__body flex flex-col gap-4">
          ${body}
          <div class="flex gap-2">
            <button
              class="${leftBtnClasses}"
              data-action="click->config#${leftBtnAction}"
              data-${customAttr}="${customAttrValue}">
              ${leftBtnText}
            </button>
            <button
              class="${rightBtnClasses}"
              data-action="click->config#${rightBtnAction}">
              ${rightBtnText}
            </button>
          </div>
        </div>
      </div>
      <div class="crayons-modal__overlay"></div>
    </div>
  `;
};

export default adminModal;
