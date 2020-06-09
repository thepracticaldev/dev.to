import { h } from 'preact';
import PropTypes from 'prop-types';
import Membership from './Membership';

const ActiveMembershipSection = ({
  activeMemberships,
  removeActiveMembership,
  currentMembershipRole,
}) => {
  return (
    <div className="p-4 grid gap-2 crayons-card mb-4">
      <h3 className="mb-2 active_members">Members</h3>
      {activeMemberships && activeMemberships.length > 0
        ? activeMemberships.map((pendingMembership) => (
          <Membership
            membership={pendingMembership}
            removeMembership={removeActiveMembership}
            membershipType="active"
            currentMembershipRole={currentMembershipRole}
            className="active-member"
          />
          ))
        : null}
    </div>
  );
};

ActiveMembershipSection.propTypes = {
  activeMemberships: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string.isRequired,
      membership_id: PropTypes.number.isRequired,
      user_id: PropTypes.number.isRequired,
      role: PropTypes.string.isRequired,
      image: PropTypes.string.isRequired,
      username: PropTypes.string.isRequired,
      status: PropTypes.string.isRequired,
    }),
  ).isRequired,
  removeActiveMembership: PropTypes.func.isRequired,
  currentMembershipRole: PropTypes.string.isRequired,
};

export default ActiveMembershipSection;
