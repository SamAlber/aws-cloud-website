const counter = document.querySelector(".counter-number"); // This line selects the first HTML element with the class counter-number and assigns it to the counter variable. 
// a method in JavaScript used to select the first element in the DOM (Document Object Model) that matches a specified CSS selector. It allows you to interact with or manipulate HTML elements directly.
// selector: A string representing a CSS selector (e.g., .class, #id, or a tag like div). 
async function updateCounter() { // The updateCounter function is marked as async, meaning it can use await inside it to handle asynchronous operations.
    let response = await fetch("https://zyst4gczkf.execute-api.us-east-1.amazonaws.com/prod/viewer-count") // Fetch the JSON data from the API.
    let data = await response.json(); // Parse the JSON response. 
    counter.innerHTML = `Views: ${data.view_count}`; //replaces the value of the counter number class with the new data number received from lambda.
    // counter.innerHTML is a property of an HTML element that represents the content inside that element, including any HTML tags. 
}

updateCounter();


// counter.innerHTML explanation

//<div class="counter-number">Old Content</div>
//<script>
//    const counter = document.querySelector(".counter-number");
//    counter.innerHTML = "New Content";
//    console.log(counter.innerHTML); // Outputs: "New Content"
//</script>

// document.querySelector(".counter-number") selects the <div> with the class counter-number. 
// counter.innerHTML = "New Content" replaces the existing content ("Old Content") with "New Content". 


// CRYPTO BAR

async function fetchCryptoPrices() {
    const apiEndpoint = "https://zyst4gczkf.execute-api.us-east-1.amazonaws.com/prod/crypto_api"; // Replace with your API Gateway URL
    const symbols = "BTC,ETH,BNB,LTC,DOGE,NEO,ADA,SOL,XRP,TRX"; // Add more symbols if needed

    // Mapping cryptocurrency symbols to their logo URLs
    const cryptoLogos = {
        BTC: "https://cryptologos.cc/logos/bitcoin-btc-logo.png",
        ETH: "https://cryptologos.cc/logos/ethereum-eth-logo.png",
        BNB: "https://cryptologos.cc/logos/binance-coin-bnb-logo.png",
        LTC: "https://cryptologos.cc/logos/litecoin-ltc-logo.png",
        DOGE: "https://cryptologos.cc/logos/dogecoin-doge-logo.png",
        NEO: "https://cryptologos.cc/logos/neo-neo-logo.png",
        ADA: "https://cryptologos.cc/logos/cardano-ada-logo.png",
        SOL: "https://cryptologos.cc/logos/solana-sol-logo.png",
        XRP: "https://cryptologos.cc/logos/xrp-xrp-logo.png",
        TRX: "https://cryptologos.cc/logos/tron-trx-logo.png",
    };

    try {
        const response = await fetch(`${apiEndpoint}?symbols=${symbols}`);
        const data = await response.json();

        if (data.prices) {
            const cryptoBar = document.getElementById("crypto-bar");
            cryptoBar.innerHTML = ""; // Clear existing content

            // Populate the bar with cryptocurrencies
            for (const [symbol, price] of Object.entries(data.prices)) {
                const item = document.createElement("div");
                item.className = "crypto-item";

                // Add a logo for each coin
                const icon = document.createElement("img");
                icon.src = cryptoLogos[symbol] || "https://via.placeholder.com/40"; // Use placeholder if logo is missing
                icon.alt = `${symbol} logo`;
                icon.style.width = "40px";
                icon.style.height = "40px";

                // Add the coin name
                const name = document.createElement("div");
                name.className = "crypto-name";
                name.textContent = symbol;

                // Add the price
                const priceElement = document.createElement("div");
                priceElement.className = "crypto-price";
                priceElement.textContent = `$${price.toFixed(2)}`;

                // Append elements to the item
                item.appendChild(icon);
                item.appendChild(name);
                item.appendChild(priceElement);

                // Append item to the crypto bar
                cryptoBar.appendChild(item);
            }
        } else {
            console.error("No prices found in response");
        }
    } catch (error) {
        console.error("Error fetching crypto prices:", error);
    }
}

// Fetch the prices once when the page loads
fetchCryptoPrices();


// Sending email form 

async function sendEmailRequest() {
    const emailInput = document.getElementById("email-input");
    const email = emailInput.value.trim(); // Get the email input and trim whitespace
    const statusDiv = document.getElementById("email-status");

    // Clear previous status messages
    statusDiv.textContent = "";

    // Validate email input
    if (!validateEmail(email)) {
        statusDiv.textContent = "Please enter a valid email address.";
        statusDiv.style.color = "red";
        return;
    }

    const apiEndpoint = "https://zyst4gczkf.execute-api.us-east-1.amazonaws.com/prod/send-cv"; // Your API Gateway endpoint

    try {
        // Show loading indicator
        statusDiv.textContent = "Sending request...";
        statusDiv.style.color = "blue";

        // Make POST request to the API Gateway
        const response = await fetch(apiEndpoint, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ email }), // Pass email in the body
        });

        const result = await response.json();

        if (response.ok) {
            statusDiv.textContent = "CV link sent successfully! Check your email.";
            statusDiv.style.color = "green";
        } else {
            // Show error message from backend
            statusDiv.textContent = result.error || "Failed to send CV. Please try again.";
            statusDiv.style.color = "red";
        }
    } catch (error) {
        console.error("Error sending email:", error);
        statusDiv.textContent = "An error occurred while sending the email. Please try again.";
        statusDiv.style.color = "red";
    }
}

// Email validation function
function validateEmail(email) {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // Simple email regex
    return regex.test(email);
}


// Cognito Part 
// 1) Your Cognito Hosted UI details
const COGNITO_DOMAIN = "YOUR_COGNITO_DOMAIN.auth.us-east-1.amazoncognito.com";
const CLIENT_ID = "YOUR_USER_POOL_CLIENT_ID";
const REDIRECT_URI = "https://www.yoursite.com"; 
// Must match what's in your Cognito User Pool Client's callback_urls

// 2) Scope + response type
const SCOPES = "openid+email+profile";
const RESPONSE_TYPE = "code";

// 3) Public file URL (the direct S3 or CloudFront link)
const PUBLIC_FILE_URL = "https://my-bucket.s3.amazonaws.com/MyCV.pdf";
// or e.g. "https://d123abcdef.cloudfront.net/MyCV.pdf"

// 4) Handle login-button click
document.getElementById("login-button").onclick = () => {
  const loginUrl = 
    `https://${COGNITO_DOMAIN}/oauth2/authorize?` +
    `client_id=${CLIENT_ID}&` +
    `response_type=${RESPONSE_TYPE}&` +
    `scope=${SCOPES}&` +
    `redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
  
  window.location.href = loginUrl;
};

// 5) On page load, check if we have a ?code= from Cognito
window.addEventListener("DOMContentLoaded", () => {
  const urlParams = new URLSearchParams(window.location.search);
  const code = urlParams.get("code");
  
  if (code) {
    exchangeCodeForTokens(code);
  }
});

// 6) Exchange authorization code for tokens
async function exchangeCodeForTokens(authCode) {
  const tokenUrl = `https://${COGNITO_DOMAIN}/oauth2/token`;

  try {
    const response = await fetch(tokenUrl, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "authorization_code",
        code: authCode,
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI
      })
    });
    
    const tokens = await response.json();
    if (tokens.id_token) {
      // Parse the ID token to get user info
      const payload = parseJwt(tokens.id_token);

      // Greet by name (or email)
      const userName = payload.name || payload.email || "User";
      document.getElementById("user-name").textContent = userName;

      // Show the authenticated section, hide login button
      document.getElementById("authenticated-section").style.display = "block";
      document.getElementById("login-button").style.display = "none";
    }
  } catch (error) {
    console.error("Token exchange error:", error);
  }
}

// 7) Utility to parse JWT token (ID token)
function parseJwt(token) {
  const base64Url = token.split(".")[1];
  const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/");
  const jsonPayload = decodeURIComponent(
    atob(base64)
      .split("")
      .map(c => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2))
      .join("")
  );
  return JSON.parse(jsonPayload);
}

// 8) Download CV button
document.getElementById("download-cv-btn").onclick = () => {
  // Because the file is public, we can just direct the user to it
  // For an immediate download, either:
  
  // Option A: Simple redirect (will open in browser or prompt for download)
  //window.location.href = PUBLIC_FILE_URL;
  
  // Option B: Use an <a download> trick to force "save as"
  const anchor = document.createElement("a");
  anchor.href = PUBLIC_FILE_URL;
  anchor.download = "MyCV.pdf"; // set desired filename
  document.body.appendChild(anchor);
  anchor.click();
  document.body.removeChild(anchor);
};


