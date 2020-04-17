import { h } from 'preact';
import PropTypes from 'prop-types';
import { defaultChildrenPropTypes } from '../../src/components/common-prop-types';

function getAdditionalClassNames({
  variant,
  className,
  contentType,
  size,
  icon,
  inverted,
  disabled,
  children,
}) {
  let additionalClassNames = '';

  if (variant && variant.length > 0 && variant !== 'primary') {
    additionalClassNames += ` crayons-btn--${variant}`;
  }

  if (size && size.length > 0 && size !== 'default') {
    additionalClassNames += ` crayons-btn--${size}`;
  }

  if (contentType && contentType.length > 0 && contentType !== 'text') {
    additionalClassNames += ` crayons-btn--${contentType}`;
  }

  if (disabled) {
    additionalClassNames += ' crayons-btn--disabled';
  }

  if (inverted) {
    additionalClassNames += ' crayons-btn--inverted';
  }

  if (className && className.length > 0) {
    additionalClassNames += ` ${className}`;
  }

  return additionalClassNames;
}

export const Button = ({
  children,
  variant = 'primary',
  tagName = 'button',
  inverted,
  contentType = 'text',
  size = 'default',
  className,
  icon,
  url,
  buttonType,
  disabled,
  onClick,
  onMouseOver,
  onMouseOut,
  onFocus,
  onBlur,
}) => {
  const ComponentName = tagName;
  const Icon = icon;
  const otherProps =
    tagName === 'button'
      ? { type: buttonType, disabled }
      : { href: disabled ? undefined : url };

  return (
    <ComponentName
      className={`crayons-btn${getAdditionalClassNames({
        variant,
        size,
        contentType,
        className,
        icon,
        inverted,
        disabled: tagName === 'a' && disabled,
        children,
      })}`}
      onClick={onClick}
      onMouseOver={onMouseOver}
      onMouseOut={onMouseOut}
      onFocus={onFocus}
      onBlur={onBlur}
      {...otherProps}
    >
      {Icon && <Icon />}
      {children}
    </ComponentName>
  );
};

Button.displayName = 'Button';

Button.defaultProps = {
  className: undefined,
  icon: undefined,
  url: undefined,
  buttonType: 'button',
  disabled: false,
  inverted: false,
  onClick: undefined,
  onMouseOver: undefined,
  onMouseOut: undefined,
  onFocus: undefined,
  onBlur: undefined,
};

Button.propTypes = {
  children: defaultChildrenPropTypes.isRequired,
  variant: PropTypes.oneOf([
    'primary',
    'secondary',
    'outlined',
    'danger',
    'ghost',
    'ghost-brand',
    'ghost-success',
    'ghost-warning',
    'ghost-danger',
  ]).isRequired,
  contentType: PropTypes.oneOf([
    'text',
    'icon-left',
    'icon-right',
    'icon',
    'icon-rounded'
  ]).isRequired,
  inverted: PropTypes.bool,
  tagName: PropTypes.oneOf(['a', 'button']).isRequired,
  className: PropTypes.string,
  icon: PropTypes.node,
  url: PropTypes.string,
  buttonType: PropTypes.string,
  disabled: PropTypes.bool,
  size: PropTypes.oneOf(['default', 's', 'l', 'xl']).isRequired,
  onClick: PropTypes.func,
  onMouseOver: PropTypes.func,
  onMouseOut: PropTypes.func,
  onFocus: PropTypes.func,
  onBlur: PropTypes.func,
};
