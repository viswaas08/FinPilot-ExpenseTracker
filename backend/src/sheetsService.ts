import { google } from 'googleapis';

const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  process.env.GOOGLE_REDIRECT_URI || 'http://localhost:5000/api/sheets/callback'
);

export function getAuthorizationUrl(): string {
  const scopes = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive.file'
  ];
  return oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: scopes,
    prompt: 'consent'
  });
}

export async function exchangeCodeForTokens(code: string) {
  const { tokens } = await oauth2Client.getToken(code);
  return tokens;
}

export async function createFinPilotSpreadsheet(accessToken: string, refreshToken?: string) {
  const auth = new google.auth.OAuth2();
  auth.setCredentials({ access_token: accessToken, refresh_token: refreshToken });

  const sheets = google.sheets({ version: 'v4', auth });

  const resource = {
    properties: {
      title: `FinPilot Finance — ${new Date().getFullYear()}`,
    },
    sheets: [
      { properties: { title: 'Dashboard' } },
      { properties: { title: 'Transactions' } },
      { properties: { title: 'Income' } },
      { properties: { title: 'Expenses' } },
      { properties: { title: 'Accounts' } },
      { properties: { title: 'Budgets' } },
      { properties: { title: 'Goals' } },
      { properties: { title: 'Subscriptions' } },
    ],
  };

  const response = await sheets.spreadsheets.create({
    requestBody: resource,
  });

  const spreadsheetId = response.data.spreadsheetId;

  // Populate header row in Transactions sheet
  if (spreadsheetId) {
    await sheets.spreadsheets.values.update({
      spreadsheetId,
      range: 'Transactions!A1:I1',
      valueInputOption: 'RAW',
      requestBody: {
        values: [
          ['Date', 'Type', 'Description', 'Category', 'Account', 'Amount', 'Currency', 'Tags', 'Notes']
        ]
      }
    });

    // Populate header row in Accounts sheet
    await sheets.spreadsheets.values.update({
      spreadsheetId,
      range: 'Accounts!A1:F1',
      valueInputOption: 'RAW',
      requestBody: {
        values: [
          ['Account', 'Type', 'Institution', 'Balance', 'Currency', 'Status']
        ]
      }
    });
  }

  return response.data;
}
