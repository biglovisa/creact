var Body = React.createClass({
  getInitialState() {
    return { skills: [] }
  },

  componentDidMount() {
    $.getJSON('/api/v1/skills.json', (response) => { this.setState({ skills: response }) });
  },

  handleSubmit(skill) {
    console.log(skill);
  }

  render() {
    return (
      <div>
        <NewSkill />
        <AllSkills skills={this.state.skills} />
      </div>
    )
  }
})
