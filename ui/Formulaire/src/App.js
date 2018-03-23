import React, { Component } from 'react';
import IPFS from 'ipfs';
import jsPDF from 'jspdf';
import "./lib/bootstrap.min.css";

class App extends Component {
  constructor(props) {
    super(props);
    this.node = new IPFS();
    this.state = {
      addedFileHash: null,
      finalHash: null,
      info1: null,
      info2: null,
      phase: 'formulary'
    }
    this.node = new IPFS();
    this.node.once('ready', () => {
      console.log('IPFS node is ready!');
      this.node.version((err, version) => {
        err ? console.error(err) : console.log('Version: ' + version.version);
      });
    });

    // bindings are necessary in order to get the proper this in the handle fct
    this.handleSubmit   = this.handleSubmit.bind(this);
    this.handleChange   = this.handleChange.bind(this);
    this.saveToIpfs     = this.saveToIpfs.bind(this);
    this.handlePublish  = this.handlePublish.bind(this);
    this.handleGoBack   = this.handleGoBack.bind(this);
  }

  handleSubmit(event) {
    event.preventDefault();
    let info1 = document.getElementById('info1').value;
    let info2 = document.getElementById('info2').value;
    this.setState({
      info1: info1,
      info2: info2,
      phase: 'results'
    });
  }

  handleChange(event) {
    event.stopPropagation();
    event.preventDefault();
    const file = event.target.files[0];
    let reader = new window.FileReader();
    reader.onloadend = () => this.saveToIpfs(reader);
    reader.readAsArrayBuffer(file);
  }

  handleGoBack(event) {
    event.stopPropagation();
    event.preventDefault();
    this.setState({
      phase: 'formulary'
    });
  }

  handlePublish(event) {
    event.stopPropagation();
    event.preventDefault();
    const doc = new jsPDF();
    const specialElementHandlers = {
    	'#editor': function(element, renderer){
    		return true;
    	},
    	'.controls': function(element, renderer){
    		return true;
    	}
    };
    const source = document.getElementsByTagName('body')[0];
    // All units are in the set measurement for the document
    // This can be changed to "pt" (points), "mm" (Default), "cm", "in"
    doc.fromHTML(source, 15, 15, {
    	'width': 170,
    	'elementHandlers': specialElementHandlers
    });
    const file = doc.output('blob');
    let reader = new window.FileReader();
    reader.onloadend = () => this.saveToIpfs(reader);
    reader.readAsArrayBuffer(file);
  }

  saveToIpfs(reader) {
    let ipfsId;
    const buffer = Buffer.from(reader.result);
    this.node.files.add(buffer)
      .then((response) => {
        ipfsId = response[0].hash;
        if (this.state.phase === 'formulary') {
          this.setState({
            addedFileHash: ipfsId
          });
        } else if (this.state.phase === 'results') {
          this.setState({
            finalHash: ipfsId,
            phase: 'final'
          });
        }
      }).catch((err) => {
        console.error(err);
      });
  }

  displayFormulary() {
    return (
      <div className="container">
        <div className="jumbotron text-center">
          <h1>Formulary</h1>
        </div>
        <div className="container" id="formulary">
          <form className="" id="captureMedia" onSubmit={this.handleSubmit}>
            <div className="input-group">
              <label><strong>Info1</strong></label>
              <input className="form-control float-right" type="text" id="info1"/>
            </div>
            <div className="input-group">
              <label><strong>Info2</strong></label>
              <input className="form-control float-right" type="number" id="info2"/>
            </div>
            <div className="input-group">
              <label><strong>File</strong></label>
              <div className="custom-file">
                <input className="float-right" type="file" id="inputGroupFile01" onChange={this.handleChange} />
              </div>
            </div>
            <button className="btn btn-primary" type="submit">Submit</button>
          </form>
        </div>
      </div>
    );
  }

  displayResults() {
    return (
      <div className="container">
        <div className="jumbotron">
          <h2>Results</h2>
        </div>
        <div className="container">
          <div>
            Info1: {this.state.info1}
          </div>
          <div>
            Info2: {this.state.info2}
          </div>
          <div>
            <a href={'https://ipfs.io/ipfs/' + this.state.addedFileHash}>
              {'https://ipfs.io/ipfs/' + this.state.addedFileHash}
            </a>
          </div>
          <div id="editor">
            <button className="btn btn-primary" onClick={this.handlePublish}>Publish to IPFS</button>
            <button className="btn btn-primary" onClick={this.handleGoBack}>Change the informations</button>
          </div>
        </div>
      </div>
    );
  }

  displayFinal() {
    return (
      <div>
        <div className="container">
          <h2>Thank you for completing the formulary!</h2>
          <div>
            Here is the hash of your formulary that you need to present in order
            to finish your postulation:
            <div className="text-center">
              {this.state.finalHash}
            </div>
            <div>
              Link to your postulation recap on IPFS:
              <a href={'https://ipfs.io/ipfs/' + this.state.finalHash}>
                {'https://ipfs.io/ipfs/' + this.state.finalHash}
              </a>
            </div>
          </div>
        </div>
      </div>
    );
  }


  render() {
    const displayElement = this.state.phase === 'formulary' ?
      this.displayFormulary() : this.state.phase === 'results' ?
        this.displayResults() : this.displayFinal();
    return (
      <div className="App">
        {displayElement}
      </div>
    );
  }
}

export default App;
