var AllSkills = React.createClass({
  handleDelete(id) {
    this.props.handleDelete(id);
  },

  onUpdate(skill) {
    this.props.onUpdate(skill);
  },

  render() {
    let skills = this.props.skills.map((skill, index) => {
      return (
        <div key={index}>
          <Skill skill={skill}
                 handleDelete={this.handleDelete.bind(this, skill.id)}
                 handleUpdate={this.onUpdate}/>
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
