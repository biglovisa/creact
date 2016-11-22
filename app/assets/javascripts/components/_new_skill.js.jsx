var NewSkill = React.createClass({

  handleClick() {
    console.log('in handle click!')
  },
  
  render() {
    return (
      <div>
        <input ref='name' placeholder='Enter name of skill' />
        <input ref='details' placeholder='Details' />
        <button onClick={this.handleClick}>Submit</button>
      </div>
    )
  }
});
