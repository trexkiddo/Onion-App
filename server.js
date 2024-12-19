const axios = require('axios');
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

require('dotenv').config({ path: 'config.env' });

const { MongoClient } = require('mongodb');

const url = process.env.MONGODB_URL;
const client = new MongoClient(url);

async function main() {
    try {
        // Connect the client
        await client.connect();
        console.log("Connected to MongoDB!");

        // Perform operations here (if needed)
    } catch (err) {
        console.error("Error connecting to MongoDB:", err);
    }
}

const bcrypt = require('bcrypt');
const crypto = require('crypto');

//API KEY for external database
const apiKey = process.env.SPOONACULAR_API_KEY;

app.use((req, res, next) =>
  {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader(
      'Access-Control-Allow-Headers',
      'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    );
    res.setHeader(
      'Access-Control-Allow-Methods',
      'GET, POST, PATCH, DELETE, OPTIONS'
    );
    next();
});

app.post('/api/login', async (req, res, next) =>
  {
    // incoming: Login, Password
    // outgoing: id, username, first_name, last_name, allergens, favorites, pantry, emailVerified, error

    var error = '';

    const { Login, Password } = req.body;

    const db = client.db('POOSD-Large-Project');
    const results = await db.collection('Users').find({username:Login}).toArray();

    let id = -1;
    let fn = '';
    let ln = '';
    let allergens = [];
    let favorites = [];
    let pantry = [];
    let emailVerified = false;

    if( results.length > 0 )
    {
      // User exists, check the password
      const storedHashedPassword = results[0].password;

      // Compare the input password with the stored hashed password
      const passwordMatch = await bcrypt.compare(Password, storedHashedPassword);

      if (passwordMatch) {
        id = results[0]._id;
        fn = results[0].first_name;
        ln = results[0].last_name;
        allergens = results[0].allergens || []; // Default to empty array if not present
        favorites = results[0].favorites || []; // Default to empty array if not present
        diet = results[0].diet || []; // Default to empty array if not present
        pantry = results[0].pantry || []; // Default to empty array if not present
        verifiedEmail = results[0].verifiedEmail || false; // Default to false if not present
      } else {
        error = 'Incorrect password';
      }
    }

    const ret = {
      id: id,
      username: Login,
      first_name:fn,
      last_name:ln,
      allergens: allergens,
      favorites: favorites,
      pantry: pantry || [],
      email: results[0]?.email || '',
      verifiedEmail: results[0].verifiedEmail || false,
      diet: diet,
      error:''
    };

    res.status(200).json(ret);
});

app.post('/api/signup', async (req, res, next) => {
  // incoming: Login, Password, FirstName, LastName, Email, Allergens(array)
  // outgoing: id, first_name, last_name, error

  let error = '';

  // FRONT END MATCH THESE VARIABLES
  const { Login, Password, FirstName, LastName, Email, Allergens } = req.body;

  const db = client.db('POOSD-Large-Project');
  const results = await db.collection('Users').find({ username:Login }).toArray();

  let id = -1;
  let fn = '';
  let ln = '';

  if (results.length === 0) {
    // User doesn't exist, create a new one

    // Hash the password
    const SaltRounds = 10;
    const HashedPassword = await bcrypt.hash(Password, SaltRounds);

    const newUser = {
      username: Login,
      password: HashedPassword,
      first_name: FirstName,
      last_name: LastName,
      email: Email,
      allergens: Allergens || [],
      favorites: [],
      pantry: [],
      verifiedEmail: false
    };

    const insertResult = await db.collection('Users').insertOne(newUser);
    id = insertResult.insertedId;
    fn = FirstName;
    ln = LastName;
  } else {
    // User already exists, return an error
    error = 'User already exists';
  }

  const ret = { id: id, first_name: fn, last_name: ln, error };
  res.status(200).json(ret);
});

//Endpoint to get detailed information of a recipe by its ID
app.get('/api/getRecipeInfo', async (req, res) => {
  // Incoming: RecipeID
  // Outgoing: id, title, image, ingredients (array), servings, readyInMinutes, sourceUrl, error

  const { RecipeID } = req.query; // Get the recipe ID from query parameters
  const apiKey = process.env.SPOONACULAR_API_KEY;

  if (!RecipeID) {
    return res.status(400).json({ error: 'Recipe ID is required' });
  }

  const url = `https://api.spoonacular.com/recipes/${RecipeID}/information?apiKey=${apiKey}`;

  try {
    // Fetch recipe details from Spoonacular
    const response = await axios.get(url);

    // Extract relevant details
    const recipeDetails = {
      id: response.data.id,
      title: response.data.title,
      image: response.data.image,
      servings: response.data.servings,
      readyInMinutes: response.data.readyInMinutes,
      ingredients: response.data.extendedIngredients.map((ingredient) => ({
        name: ingredient.name,
        amount: ingredient.amount,
        unit: ingredient.unit,
      })),
      sourceUrl: response.data.sourceUrl,
    };

    // Send back the detailed recipe information
    res.status(200).json(recipeDetails);
  } catch (error) {
    console.error('Error fetching recipe details:', error);
    res.status(500).json({ error: 'Failed to fetch recipe details' });
  }
});

//UNTESTED
app.delete('/api/deleteUser', async (req, res) => {
  // Incoming: userId (or username)
  // Outgoing: success (boolean), error (string)

  const { userId } = req.body; // Assuming you pass userId in the request body
  const db = client.db('POOSD-Large-Project');
  let error = '';

  try {
    // Check if the user exists
    const user = await db.collection('Users').findOne({ _id: new ObjectId(userId) });

    if (!user) {
      error = 'User not found';
      return res.status(404).json({ success: false, error });
    }

    // Delete the user
    const deleteResult = await db.collection('Users').deleteOne({ _id: new ObjectId(userId) });

    if (deleteResult.deletedCount === 1) {
      return res.status(200).json({ success: true, error: '' });
    } else {
      error = 'Failed to delete user';
      return res.status(500).json({ success: false, error });
    }
  } catch (err) {
    error = err.message;
    return res.status(500).json({ success: false, error });
  }
});

// Endpoint to add a recipe to the user's favorites
app.post('/api/addfavorite', async (req, res) => {
  // Incoming: Login (username), RecipeID
  // Outgoing: id, first_name, last_name, error

  let error = '';

  const { Login, RecipeID } = req.body;

  const db = client.db('POOSD-Large-Project');

  try {
    // Find the user by username
    const user = await db.collection('Users').findOne({ username: Login });

    if (!user) {
      // User not found
      error = 'User not found';
      return res.status(404).json({ error });
    }

    // Check if the RecipeID is already in the favorites array
    if (user.favorites.includes(RecipeID)) {
      error = 'Recipe already in favorites';
      return res.status(400).json({ error });
    }

    // Push the RecipeID into the user's favorites array
    const updateResult = await db.collection('Users').updateOne(
      { username: Login },
      { $push: { favorites: RecipeID } }
    );

    // Check if the update was successful
    if (updateResult.modifiedCount > 0) {
      return res.status(200).json({
        id: user._id,
        first_name: user.first_name,
        last_name: user.last_name,
        error: 'Success'
      });
    } else {
      error = 'Failed to add favorite recipe';
      return res.status(500).json({ error });
    }
  } catch (err) {
    console.error('Error adding favorite recipe:', err);
    error = 'Error adding favorite';
    return res.status(500).json({ error });
  }
});

app.delete('/api/removefavorite', async (req, res) => {
  // Incoming: Login (username), RecipeID
  // Outgoing: id, first_name, last_name, error

  let error = '';

  const { Login, RecipeID } = req.body;
  const db = client.db('POOSD-Large-Project');

  try {
    // Find the user by username
    const user = await db.collection('Users').findOne({ username: Login });

    if (!user) {
      // User not found
      error = 'User not found';
      return res.status(404).json({ error });
    }

    // Check if the RecipeID is in the favorites array
    if (!user.favorites.includes(RecipeID)) {
      error = 'Recipe not in favorites';
      return res.status(400).json({ error });
    }

    // Remove the RecipeID from the user's favorites array
    const updateResult = await db.collection('Users').updateOne(
      { username: Login },
      { $pull: { favorites: RecipeID } }
    );

    // Check if the update was successful
    if (updateResult.modifiedCount > 0) {
      return res.status(200).json({
        id: user._id,
        first_name: user.first_name,
        last_name: user.last_name,
        error: 'Success'
      });
    } else {
      error = 'Failed to remove favorite recipe';
      return res.status(500).json({ error });
    }
  } catch (err) {
    console.error('Error removing favorite recipe:', err);
    error = 'Error removing favorite';
    return res.status(500).json({ error });
  }
});

app.get('/api/searchById', async (req, res) => {
  const recipeId = req.query.id; // Get the recipe ID from request
  const apiKey = process.env.SPOONACULAR_API_KEY;
  const foreign_url = `https://api.spoonacular.com/recipes/${recipeId}/information?apiKey=${apiKey}`;

  try {
    const response = await axios.get(foreign_url);

    // Extract and format the response
    const recipeData = {
      id: response.data.id,
      title: response.data.title,
      image: response.data.image,
      imageType: response.data.imageType,
    };

    res.json(recipeData); // Send the formatted response
  } catch (error) {
    console.error(`Error fetching recipe by ID (${recipeId}):`, error.response?.data || error.message);
    res.status(500).json({ error: 'Failed to fetch recipe information' });
  }
});

// Endpoint to search recipes by name, and ingredients
app.get('/api/searchRecipe', async (req, res) => {
  const query = req.query.q; // Get the search query from request
  const userAllergens = req.query.allergens || ''; // Get user's allergens as a comma-separated string
  const foreign_url = `https://api.spoonacular.com/recipes/complexSearch?query=${query}&intolerances=${userAllergens}&apiKey=${apiKey}`;

  try {
    const response = await axios.get(foreign_url);
    res.json(response.data); // Return the API response data to the client
  } catch (error) {
    console.error('Error fetching recipes:', error);
    res.status(500).json({ error: 'Failed to fetch recipes' });
  }
});

// Endpoint to search recipes by ingredients with a 65% match requirement
app.get('/api/searchPantry', async (req, res) => {
  const ingredients = req.query.ingredients; // Get ingredients as a comma-separated string
  const allergens = req.query.allergens || ''; // Get allergens as a comma-separated string
  const requiredPercentage = 0.5; // Minimum percentage of matching ingredients required

  // Construct the Spoonacular API URL
  const foreign_url = `https://api.spoonacular.com/recipes/findByIngredients?ingredients=${ingredients}&number=50&apiKey=${apiKey}`;

  if (!ingredients) {
    return res.status(400).json({ error: 'Ingredients query parameter is required' });
  }

  try {
    const response = await axios.get(foreign_url);
    const recipes = response.data; // Array of recipe objects from Spoonacular

    // Filter out recipes that contain allergens
    const filteredRecipes = recipes.filter(recipe => {
      if (!allergens) return true; // No allergens specified, include all recipes
      const allergenList = allergens.split(',').map(a => a.trim().toLowerCase());

      // Check if any ingredient (used or missed) is in the allergens list
      const allIngredients = [
        ...recipe.usedIngredients,
        ...recipe.missedIngredients
      ].map(ingredient => ingredient.name.toLowerCase());

      // Return false if any allergen matches any ingredient
      return !allergenList.some(allergen => allIngredients.includes(allergen));
    });

    // Process recipes to calculate match percentage and filter
    const processedRecipes = filteredRecipes
      .map(recipe => {
        const totalRecipeIngredients = recipe.usedIngredients.length + recipe.missedIngredients.length;
        const usedIngredientCount = recipe.usedIngredients.length;
        const matchPercentage = usedIngredientCount / totalRecipeIngredients;

        return {
          ...recipe,
          matchPercentage: matchPercentage
        };
      })
      .filter(recipe => recipe.matchPercentage >= requiredPercentage) // Filter recipes by threshold
      .sort((a, b) => b.matchPercentage - a.matchPercentage); // Sort by match percentage in descending order

    res.json(processedRecipes); // Return the processed and sorted recipes to the client
  } catch (error) {
    console.error('Error fetching recipes:', error);
    res.status(500).json({ error: 'Failed to fetch recipes' });
  }
});

app.post('/api/updatePantry', async (req, res) => {
  // Incoming: Login (username), Pantry (array of strings)
  // Outgoing: updated pantry, error

  let error = '';

  // Destructure the incoming request body
  const { Login, Pantry } = req.body;

  // Validate input
  if (!Login || !Array.isArray(Pantry)) {
    return res.status(400).json({ error: 'Invalid request body. Login and Pantry are required.' });
  }

  const db = client.db('POOSD-Large-Project');

  try {
    // Find the user by username
    const user = await db.collection('Users').findOne({ username: Login });

    if (!user) {
      // If the user doesn't exist
      error = 'User not found';
      return res.status(404).json({ error });
    }

    // Update the pantry array
    const updateResult = await db.collection('Users').updateOne(
      { username: Login },
      { $set: { pantry: Pantry } } // Set the pantry array to the new array
    );

    if (updateResult.modifiedCount > 0) {
      // Fetch the updated pantry to return to the user
      const updatedUser = await db.collection('Users').findOne({ username: Login });
      return res.status(200).json({
        pantry: updatedUser.pantry,
        error: 'Success'
      });
    } else {
      error = 'Failed to update pantry';
      return res.status(500).json({ error });
    }
  } catch (err) {
    console.error('Error updating pantry:', err);
    error = 'Error updating pantry';
    return res.status(500).json({ error });
  }
});

app.post('/api/addAllergen', async (req, res, next) => {
  // Incoming: Login (username), Allergen
  // Outgoing: error

  let error = '';

  // Destructure the incoming request body
  const { Login, Allergen } = req.body;  // Recipe will be an object like { id, title, image, etc. }

  const db = client.db('POOSD-Large-Project');

  try {
    // Find the user by username
    const user = await db.collection('Users').findOne({ username: Login });

    if (!user) {
      // If the user doesn't exist
      error = 'User not found';
      return res.status(404).json({ error });
    }

    // Push the new recipe into the user's favorites array
    const updateResult = await db.collection('Users').updateOne(
      { username: Login },
      { $push: { allergens: Allergen } }
    );

    if (updateResult.modifiedCount > 0) {
      // If the update was successful
      return res.status(200).json({
        id: user._id,
        first_name: user.first_name,
        last_name: user.last_name,
        error: 'Success'
      });
    } else {
      error = 'Failed to add allergen';
      return res.status(500).json({ error });
    }
  } catch (err) {
    console.error('Error adding allergen:', err);
    error = 'Error adding allergen';
    res.status(500).json({ error });
  }

  const ret = {error};
  res.status(200).json(ret);
});

app.delete('/api/removeAllergen', async (req, res) => {
  // Incoming: Login (username), Allergen
  // Outgoing: id, first_name, last_name, error

  let error = '';

  const { Login, Allergen } = req.body; // Extract Login and Allergen from the request body
  const db = client.db('POOSD-Large-Project');

  try {
    // Find the user by username
    const user = await db.collection('Users').findOne({ username: Login });

    if (!user) {
      // User not found
      error = 'User not found';
      return res.status(404).json({ error });
    }

    // Check if the Allergen is in the user's allergens array
    if (!user.allergens.includes(Allergen)) {
      error = 'Allergen not in user\'s allergen list';
      return res.status(400).json({ error });
    }

    // Remove the Allergen from the user's allergens array
    const updateResult = await db.collection('Users').updateOne(
      { username: Login },
      { $pull: { allergens: Allergen } } // Use $pull to remove the allergen
    );

    // Check if the update was successful
    if (updateResult.modifiedCount > 0) {
      return res.status(200).json({
        id: user._id,
        first_name: user.first_name,
        last_name: user.last_name,
        error: 'Success'
      });
    } else {
      error = 'Failed to remove allergen';
      return res.status(500).json({ error });
    }
  } catch (err) {
    console.error('Error removing allergen:', err);
    error = 'Error removing allergen';
    return res.status(500).json({ error });
  }
});

// Endpoint to fetch favorite recipes by IDs from Spoonacular API
app.post('/api/fetchFavorites', async (req, res) => {
  // Incoming: Login (username)
  // Outgoing: favoriteRecipes (array), error

  let error = '';
  const { Login } = req.body;
  const apiKey = process.env.SPOONACULAR_API_KEY;

  const db = client.db('POOSD-Large-Project');

  try {
    // Find the user by username
    const user = await db.collection('Users').findOne({ username: Login });

    if (!user) {
      // User not found
      error = 'User not found';
      return res.status(404).json({ favoriteRecipes: [], error });
    }

    // Get the list of favorite recipe IDs
    const favoriteIDs = user.favorites || [];

    if (favoriteIDs.length === 0) {
      // No favorites found
      return res.status(200).json({ favoriteRecipes: [], error: '' });
    }

    // Fetch recipe details by IDs using Spoonacular API
    const recipeDetailsPromises = favoriteIDs.map(async (recipeID) => {
      const url = `https://api.spoonacular.com/recipes/${recipeID}/information?apiKey=${apiKey}`;
      try {
        const response = await axios.get(url);
        // Return a simplified object with id, title, image, and imageType
        return {
          id: response.data.id,
          title: response.data.title,
          image: response.data.image,
          imageType: response.data.imageType,
        };
      } catch (err) {
        console.error(`Error fetching details for recipe ID "${recipeID}":`, err);
        return null; // Skip any recipe that fails
      }
    });

    // Resolve all requests
    const recipeDetails = await Promise.all(recipeDetailsPromises);

    // Filter out any null responses
    const favoriteRecipes = recipeDetails.filter((recipe) => recipe !== null);

    // Return the favorite recipes list
    res.status(200).json({ favoriteRecipes, error: '' });
  } catch (err) {
    console.error('Error fetching favorites:', err);
    error = 'Error fetching favorites';
    res.status(500).json({ favoriteRecipes: [], error });
  }
});

// Password Reset
const nodemailer = require('nodemailer');
const GMAIL_USER = process.env.GMAIL_USER;
const GMAIL_PASS = process.env.GMAIL_PASS;

// Nodemailer transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: GMAIL_USER,
    pass: GMAIL_PASS,
  },
});

app.post('/api/requestPasswordReset', async (req, res) => {
  // Incoming: Email
  // Outgoing: error
  const { Email } = req.body;
  const db = client.db('POOSD-Large-Project');

  try {
    // Check if user exists
    const user = await db.collection('Users').findOne({ email: Email });
    if (!user) {
      return res.status(400).json({ error: 'Email not found' });
    }

    // Generate a one-time reset code (6-digit numeric)
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    const resetExpires = Date.now() + 15 * 60 * 1000; // 15-minute expiration

    // Save the reset code and its expiration in the user's record
    await db.collection('Users').updateOne(
      { email: Email },
      { $set: { resetCode, resetExpires } }
    );

    // Send the reset code via email
    const mailOptions = {
      from: GMAIL_USER,
      to: Email,
      subject: 'Password Reset Code',
      text: `Your password reset code is: ${resetCode}. This code is valid for 15 minutes.`,
    };

    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: 'Password reset code sent.' });
  } catch (error) {
    console.error('Error sending email:', error);
    res.status(500).json({ error: 'Failed to send password reset email' });
  }
});

app.post('/api/validatePasswordReset', async (req, res) => {
  // Incoming: Email, Code, NewPassword
  // Outgoing: error
  const { Email, Code, NewPassword } = req.body;
  const db = client.db('POOSD-Large-Project');

  try {
    // Find the user
    const user = await db.collection('Users').findOne({ email: Email });
    if (!user) {
      return res.status(400).json({ error: 'Email not found' });
    }

    // Check if the reset code is valid
    if (!user.resetCode || !user.resetExpires) {
      return res.status(400).json({ error: 'No reset code found. Please request a new one.' });
    }

    // Check if the reset code matches and has not expired
    if (user.resetCode !== Code) {
      return res.status(400).json({ error: 'Invalid reset code' });
    }

    if (Date.now() > user.resetExpires) {
      return res.status(400).json({ error: 'Reset code has expired' });
    }

    // Hash the new password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(NewPassword, saltRounds);

    // Update the user's password and clear reset code fields
    await db.collection('Users').updateOne(
      { email: Email },
      {
        $set: { password: hashedPassword },
        $unset: { resetCode: '', resetExpires: '' },
      }
    );

    res.status(200).json({ message: 'Password reset successful' });
  } catch (error) {
    console.error('Error during password reset validation:', error);
    res.status(500).json({ error: 'An error occurred during the password reset process' });
  }
});

// Email Verification WIP
app.post('/api/requestEmailVerification', async (req, res) => {
  // Incoming: username
  // Outgoing: error
  const { username } = req.body;
  const db = client.db('POOSD-Large-Project');

  try {
    // Find the user by username
    const user = await db.collection('Users').findOne({ username: username });
    if (!user) {
      return res.status(400).json({ error: 'Username not found' });
    }

    // Check if email already verified
    if (user.verifiedEmail) {
      return res.status(400).json({ error: 'Email is already verified' });
    }

    // Generate a one-time verification code (6-digit numeric)
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const verificationExpires = Date.now() + 15 * 60 * 1000; // 15-minute expiration

    // Save the verification code and its expiration in the user's record
    await db.collection('Users').updateOne(
      { username: username },
      { $set: { verificationCode, verificationExpires } }
    );

    // Send the verification code via email
    const mailOptions = {
      from: GMAIL_USER,
      to: user.email,
      subject: 'Email Verification Code',
      text: `Your email verification code is: ${verificationCode}. This code is valid for 15 minutes.`,
    };

    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: 'Email verification code sent.' });
  } catch (error) {
    console.error('Error sending email verification:', error);
    res.status(500).json({ error: 'Failed to send email verification code' });
  }
});

app.post('/api/validateEmailVerification', async (req, res) => {
  // Incoming: username, Code
  // Outgoing: message or error
  const { username, Code } = req.body;
  const db = client.db('POOSD-Large-Project');

  try {
    // Find the user by username
    const user = await db.collection('Users').findOne({ username: username });
    if (!user) {
      return res.status(400).json({ error: 'Username not found' });
    }

    // Check if the verification code is valid
    if (!user.verificationCode || !user.verificationExpires) {
      return res.status(400).json({ error: 'No verification code found. Please request a new one.' });
    }

    // Check if the verification code matches and has not expired
    if (user.verificationCode !== Code) {
      return res.status(400).json({ error: 'Invalid verification code' });
    }

    if (Date.now() > user.verificationExpires) {
      return res.status(400).json({ error: 'Verification code has expired' });
    }

    console.log('Marking email as verified for user:', username);
    await db.collection('Users').updateOne(
      { username: username },
      {
        $set: { verifiedEmail: true },
        $unset: {
          verificationCode: '',
          verificationExpires: '',
        },
      }
    );
    console.log('User marked as verified successfully:', username);

    res.status(200).json({ message: 'Email verified successfully' });
  } catch (error) {
    console.error('Error during email verification:', error);
    res.status(500).json({ error: 'An error occurred during email verification' });
  }
});

// Routes and middleware...
module.exports = app; // Export the app instance

if (require.main === module) {
  app.listen(5000, '0.0.0.0', () => console.log('Server running on port 5000'));
}