import * as signalR from '@aspnet/signalr';
import * as axios from 'axios';

import { settings } from '../Settings';
const api = `/api/Pets`;

export const Status = {
    None: 1,
    Ok: 2,
    Bad: 3
};

export class PetInfo {
    constructor(base64) {
        this.base64 = base64;
    }
}

const initialState = {
    isUploading: false,
    isThinking: false,
    id: null,
    image: null,
    approved: false,
    message: ''
};

function postImage(pet) {
    let fetchTask = fetch(api, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(pet)
    })
    .then(response => response.json());

    return fetchTask;
}

function requestSignalRToken() {
    /*let fetchTask = fetch(`${settings().petsConfig.api}/api/SignalRInfo`, {
         method: 'GET'
    })
    .then(response => response.json());*/

    let fetchTask = fetch(`${settings().petsConfig.api}/api/SignalRInfo`, {
        method: 'POST',
        headers: {
            'Accept': 'application/json'
         //   'Content-Type': 'application/json'
        }
    })
        .then(response => response.json());

    /*let fetchTask = fetch(`${settings().petsConfig.api}/api/SignalRInfo`, {
        method: 'GET',
        headers: 
            'Access-Control-Allow-Origin': '*'
        }
    })
        .then(response => response.json());*/

    /*let fetchTask = fetch(`${settings().petsConfig.api}/api/SignalRInfo`)
        .then(response => response.json());*/

    /*let fetchTask = axios.post(`${settings().petsConfig.api}/api/SignalRInfo`, null, getAxiosConfig())
        .then(response => response.json());*/

    return fetchTask;
}

function getAxiosConfig() {
    const config = {
        headers: {
            'Access-Control-Allow-Origin' : '*'
        }
    };
    return config;
}


export const actionCreators = {
    init: () => (dispatch, getState) => {
        dispatch({ type: 'INIT_ACTION'});
    },

    uploadPet: (pet) => async (dispatch, getState) => {
        //console.log('avant appel de requestSignalRToken');
        const tokenInfo = await requestSignalRToken();
        //console.log('retour de requestSignalRToken');
        //console.log(tokenInfo.accessKey);
        const options = {
            accessTokenFactory: () => tokenInfo.accessKey
            //accessTokenFactory: () => settings().petsConfig.signalRAccessKey
        };

        const connection = new signalR.HubConnectionBuilder()
            .withUrl(tokenInfo.endpoint, options)
            .configureLogging(signalR.LogLevel.Debug)
            .build();

        
        /*const connection = new signalR.HubConnectionBuilder()
            .withUrl(settings().petsConfig.signalREndpoint, options)
            .configureLogging(signalR.LogLevel.Information)
            .build();*/

        connection.on('ProcessDone', (data) => {
            dispatch({ type: 'END_SOCKET', approved: data.IsApproved, message: data.Message });
        });

        //var logmsg = logmsg.concat('Suite a END_SOCKET ',approved,' ',message));
        //console.log(logmsg);
        //console.log(approved);
        //console.log(message);
        console.log('Event END_SOCKET');  

        connection.onclose(() => console.log('server closed'));

        connection.logging = true;


        dispatch({ type: 'REQUEST_PET_UPLOAD_ACTION', image: pet.base64 });

        const id = await postImage(pet);
        dispatch({ type: 'RECEIVE_PET_UPLOAD_ACTION', id: id });
  
        dispatch({ type: 'START_SOCKET' });
        connection.start().catch(console.error);
    }
};

export const reducer = (state, action) => {
    switch (action.type) {
        case 'INIT_ACTION':
            return {
                ...state, isUploading: false, isThinking: false, image: null, approved: null, message: ''};
        case 'REQUEST_PET_UPLOAD_ACTION':
            return { ...state, isUploading: true, isThinking: false, image: action.image, approved: null, message: '' };
        case 'RECEIVE_PET_UPLOAD_ACTION':
            return { ...state, isUploading: false, isThinking: false, id: action.id };
        case 'START_SOCKET':
            return { ...state, isUploading: false, isThinking: true };
        case 'END_SOCKET':
            return { ...state, isUploading: false, isThinking: false, image: null, approved: action.approved, message: action.message };
        default:
            return state || { ...initialState };
    }
};
