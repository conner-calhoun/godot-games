const WebSocket = require('ws')
const url = 'ws://localhost:9080'
const conn1 = new WebSocket(url)
const conn2 = new WebSocket(url)
 
conn1.onopen = () => {
    // Open the first lobby
    conn1.send('J: HELLO\n') 
}
 
conn1.onerror = (error) => {
    console.log(`WebSocket error: ${error}`)
}
 
conn1.onmessage = (e) => {

    if (e.data.startsWith("J:")) {
        // Parse the received message for a lobby name
        lobbyName = e.data.substr(e.data.indexOf("J") + 3, e.data.length)
    }
}

conn2.onopen = () => {
    // Join the HELLO lobby
    conn2.send('J: HELLO\n') 
}
 
conn2.onerror = (error) => {
    console.log(`WebSocket error: ${error}`)
}
 
conn2.onmessage = (e) => {

    if (e.data.startsWith("J:")) {
        // Parse the received message for a lobby name
        lobbyName = e.data.substr(e.data.indexOf("J") + 3, e.data.length)
    }
}
