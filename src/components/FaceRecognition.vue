<template>
  <v-container grid-list-xs>
    <input type="file" id="file-input" accept="image/*" />

    <v-layout row wrap>
      <v-flex xs12 sm6 pa-2>
        <v-alert v-if="isSuccess" type="success">Your photo is analyzed succesfully!</v-alert>
        <v-alert
          v-if="!isSuccess"
          type="info"
        >Submit your image to Azure Face API then broadcast your attributes to your summercamp friends using SignalR</v-alert>

        <v-img :src="myphoto" ref="img" width="300px"></v-img>
         <v-card>
          <v-card-title primary-title style="padding-top:13px">
            <div>
              <v-text-field label="your name" placeholder="your name is required" v-model="myName"></v-text-field>
              <v-radio-group v-model="myCharacter" column>
                <v-radio label="interovert" value="interovert"></v-radio>
                <v-radio label="extrovert" value="extrovert"></v-radio>
              </v-radio-group>

              <v-btn v-on:click="faceAnalyze" :disabled="!isValid" small>Broadcast your attriutes</v-btn>
             
             </div>
          </v-card-title>
        </v-card>
      </v-flex>
      <v-flex xs12 sm6 pa-2>
         <v-card v-if="myDescription!=''">
          <v-card-title primary-title style="padding-top:13px">
                <div class="mt-10" v-html="myDescription"></div>
          </v-card-title>
        </v-card>
      </v-flex >
     
    </v-layout>
<hr>
<h2 v-if="people.length>0" >Broadcasted AI detail from your summer camp friends:</h2>
    <v-layout row wrap>
      <v-flex xs12 sm6 pa-2>
        <v-card>
          <div
            v-for="(item, index) in people"
            v-bind:item="item"
            v-bind:index="index"
            v-bind:key="item.id"
          >
            <v-card-title>{{item.name}}</v-card-title>
            <v-card-subtitle>{{item.type}}</v-card-subtitle>
            <v-card-text>
              <div v-html="item.detail"></div>
            </v-card-text>
          </div>
        </v-card>
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>
/* eslint-disable */
import { HubConnection, HubConnectionBuilder } from "@aspnet/signalr";
import * as signalR from "@aspnet/signalr";
const { BlobServiceClient } = require("@azure/storage-blob");
import axios from "axios";

export default {
  name: "facephoto",
  data() {
    return {
      myphoto: "",
      myName: "",
      isSuccess: false,
      myCharacter: "interovert",
      myDescription: "",
      photoPublicUrl: "",
      isUploaded: false,
      people: [],                    
      // apiBaseUrl: "https://summercampfriendsfunctions.azurewebsites.net/api", FaceDetectEndpoint: "FaceDetect?code=Zw8isQkKfFnTvl5u4ny2atwaoMw3a7uTBc8b3eseOlm/aenSxBHJ2g==",
      apiBaseUrl: "http://localhost:7071/api",   FaceDetectEndpoint: "FaceDetect",
      hubConnection: HubConnection
    };
  },
  mounted() {
    const fileInput = document.getElementById("file-input");
    fileInput.addEventListener("change", e => this.uploadFiles(e.target.files));
  },
  created: function() {
    this.hubConnection = new signalR.HubConnectionBuilder()
      .withUrl(`${this.apiBaseUrl}`, { withCredentials: true })
      .build();

    this.hubConnection.on(
      "summercampBroadcastedDetail",
      this.BroadcastedDetailRecieved
    );
    this.hubConnection
      .start()
      .then(() => {
        console.log("connection to SignalR started");
      })
      .catch(e => {
        console.error(
          `An error occurred while connecting to operations hub. Details ${e}`
        );

      });
  },
  computed: {
    isValid() {
      return (
        this.myName.trim() != "" &&
        this.isUploaded == true &&
        this.isSuccess == false
      );
    }
  },
  methods: {
    async uploadFiles(files) {
      try {
        this.myphoto = window.URL.createObjectURL(files[0]);
        if (this.myphoto != "" && typeof this.myphoto != "undefined") {
          console.log(this.myphoto, "true");
          this.isUploaded = true;
        } else {
          console.log(his.myphoto, "fasel");

          this.isUploaded = false;
        }
        console.log(this.myphoto);
        const file = files[0];
        const STORAGE_ACCOUNT_NAME = "summercampblobphoto";
        const containerName = "images";
        const sassString ="";
        const blobServiceClient = new BlobServiceClient(
          `https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net?${sassString}`
        );
        const containerClient = blobServiceClient.getContainerClient(
          containerName
        );
        const blobClient = containerClient.getBlobClient(
          new Date().getTime() + file.name
        );
        const blockBlobClient = blobClient.getBlockBlobClient();
        await blockBlobClient.uploadBrowserData(file);
        this.photoPublicUrl = blockBlobClient.url;
        console.log(
          "File URL  uploaded to azure blob storage",
          this.photoPublicUrl
        );
      } catch (error) {
        console.log("error", error);
      }
    },
    async faceAnalyze() {
      try {
        if (this.photoPublicUrl != "") {
          const headers = {
            "Content-Type": "application/json"
          };
          const params = {
            name: this.myName,
            type: this.myCharacter
          };
          let response = await axios.post(
            `${this.apiBaseUrl}/${this.FaceDetectEndpoint}`,
            this.photoPublicUrl,
            { params: params },
            { headers: headers }
          );
          if (response && response.data) {
            this.myDescription = response.data;
            this.isSuccess = true;
          }
        } else {
          alert("your photo hasnot been accessible");
        }
      } catch (error) {
        console.log("Error in calling azure function" + error);
        this.isSuccess = false;
        throw error;
      }
    },
    BroadcastedDetailRecieved(personAttributes) {
      console.log("person", personAttributes);
      if (personAttributes) {
        this.people.unshift(personAttributes);
      }
    }
  }
};
</script>
