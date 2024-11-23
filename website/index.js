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



