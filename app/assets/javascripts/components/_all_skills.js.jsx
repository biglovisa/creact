var AllSkills = React.createClass({
  render() {
    let skills = this.props.skills.map((skill, index) => {
      return (
        <div key={index}>
          <h3>{skill.name}</h3>
          <p><strong>Level:</strong> {skill.level}</p>
          <p>{skill.details}</p>
        </div>
      )
    });

    return (
      <div>
        {skills}
      </div>
    )
  }
});
