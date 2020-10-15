import { h } from 'preact';
import { renderHook } from '@testing-library/preact-hooks';
import { fireEvent, render } from '@testing-library/preact';
import { KeyboardShortcuts, useKeyboardShortcuts } from '../useKeyboardShortcuts.jsx';

describe('Keyboard shortcuts for components', () => {
  describe('useKeyboardShortcuts', () => {
    it('should fire a function when keydown is detected', () => {
      const shortcut = {
        KeyK: jest.fn()
      };

      renderHook(() =>
        useKeyboardShortcuts(shortcut, document),
      );
      fireEvent.keyDown(document, { code: "KeyK" });

      expect(shortcut.KeyK).toHaveBeenCalledTimes(1);
    });
    
    it('should not add event listener if shortcut object is empty', () => {
      HTMLDocument.prototype.addEventListener = jest.fn();

      renderHook(() =>
        useKeyboardShortcuts({}, document),
      );

      expect(HTMLDocument.prototype.addEventListener).not.toHaveBeenCalled();
    });

    it('should add event listener to window', () => {
      HTMLDocument.prototype.addEventListener = jest.fn();

      renderHook(() =>
        useKeyboardShortcuts({
          KeyK: null
        }, document),
      );

      expect(HTMLDocument.prototype.addEventListener).toHaveBeenCalledTimes(1);
    });

    it('should not fire a function when keydown is detected in element', () => {
      const shortcut = {
        KeyK: jest.fn()
      };
      const eventTarget = document.createElement('textarea') // eventTarget set since the default is window

      renderHook(() =>
        useKeyboardShortcuts(shortcut, document),
        eventTarget,
      );
      fireEvent.keyDown(eventTarget, { code: "KeyK" });

      expect(shortcut.KeyK).not.toHaveBeenCalled();
    });

    it('should remove event listener when the hook is unmounted', () => {
      HTMLDocument.prototype.addEventListener = jest.fn();
      HTMLDocument.prototype.removeEventListener = jest.fn();

      const { unmount } = renderHook(() =>
        useKeyboardShortcuts({ KeyK: null }, document),
      );

      unmount();

      expect(HTMLDocument.prototype.addEventListener).toHaveBeenCalledTimes(1);
      expect(HTMLDocument.prototype.removeEventListener).toHaveBeenCalledTimes(1);
    });
  });

  describe('<KeyboardShortcuts />', () => {
    it('should not add event listener if shortcut object is empty', () => {
      HTMLDocument.prototype.addEventListener = jest.fn();

      render(() =>
        <KeyboardShortcuts eventTarget={document} />,
      );

      expect(HTMLDocument.prototype.addEventListener).not.toHaveBeenCalled();
    });

    it('should add event listener to window', () => {
      HTMLDocument.prototype.addEventListener = jest.fn();

      render(() =>
        <KeyboardShortcuts eventTarget={document} shortcuts={{ KeyK: null }} />,
      );

      expect(HTMLDocument.prototype.addEventListener).toHaveBeenCalledTimes(1);
    });

    it('should remove event listener when the hook is unmounted', () => {
      HTMLDocument.prototype.addEventListener = jest.fn();
      HTMLDocument.prototype.removeEventListener = jest.fn();

      const { unmount } = render(() =>
        <KeyboardShortcuts eventTarget={document} shortcuts={{ KeyK: null }} />,
      );

      unmount();
      expect(HTMLDocument.prototype.addEventListener).toHaveBeenCalledTimes(1);
      expect(HTMLDocument.prototype.removeEventListener).toHaveBeenCalledTimes(1);
    });
  });
});
