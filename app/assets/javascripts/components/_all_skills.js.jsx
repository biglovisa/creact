var AllSkills = React.createClass({
  handleDelete(id) {
    this.props.handleDelete(id);
  },

  render() {
    let skills = this.props.skills.map((skill, index) => {
      return (
        <div key={index}>
          <h3>{skill.name}</h3>
          <p><strong>Level:</strong> {skill.level}</p>
          <p>{skill.details}</p>
          <button onClick={this.handleDelete.bind(this, skill.id)}>Delete</button>
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
