/* wehttamsnaps StreamElements overlay helpers.
   Shared utility for the alerts/now-playing/dock widgets. Keeps the brand
   colour vars in sync and provides a tiny event bridge for StreamElements
   Custom Widgets. */

(function (global) {
  'use strict';
  const BRAND = {
    purple:  '#8A2BE2',
    cyan:    '#00E5FF',
    magenta: '#FF46B4',
  };

  /* Apply the brand colours to any element with data-brand attributes.
     e.g. <span data-brand="cyan">text</span> */
  function applyBrand(root) {
    (root || document).querySelectorAll('[data-brand]').forEach(function (el) {
      const c = BRAND[el.getAttribute('data-brand')];
      if (c) { el.style.color = c; el.style.textShadow = '0 0 6px ' + c; }
    });
  }

  /* StreamElements Custom Widget event bridge.
     SE calls window.SE_EVENT(eventData) when you register this as a Custom
     Widget's "Widget Code". We dispatch to type-specific handlers. */
  const handlers = {};
  function on(type, fn) { (handlers[type] = handlers[type] || []).push(fn); }
  global.SE_EVENT = function (data) {
    (handlers[data && data.type] || []).forEach(function (fn) { try { fn(data); } catch (e) {} });
  };

  /* Convenience: render an alert of a given type into a container. */
  function renderAlert(container, alert) {
    const el = document.createElement('div');
    el.className = 'alert neon-bar';
    el.innerHTML =
      '<div class="icon">' + (alert.icon || '★') + '</div>' +
      '<div class="body">' +
        '<div class="type">' + (alert.type || '') + '</div>' +
        '<div class="who">'  + (alert.who  || '') + '</div>' +
        '<div class="msg">'  + (alert.msg  || '') + '</div>' +
      '</div>' +
      '<div class="tag">@wehttamsnaps</div>';
    container.innerHTML = '';
    container.appendChild(el);
    if (alert.duration) {
      setTimeout(function () { el.classList.add('out'); }, alert.duration);
    }
    return el;
  }

  global.WS = { BRAND: BRAND, applyBrand: applyBrand, on: on, renderAlert: renderAlert };
  document.addEventListener('DOMContentLoaded', function () { applyBrand(); });
})(window);
