using DbUp;

string connectionString = args.FirstOrDefault() ?? "Server=localhost:5432;Database=devsquare;User Id=sa;Password=yourStrong(!)Password;";

EnsureDatabase.For.PostgresqlDatabase(connectionString);

var upgrader = DeployChanges.To.PostgresqlDatabase(connectionString).LogToConsole().WithScriptsFromFileSystem("Scripts").Build();

var result = upgrader.PerformUpgrade();

if (!result.Successful)
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine(result.Error);
    Console.ResetColor();
}
else
{
    Console.ForegroundColor = ConsoleColor.Green;
    Console.WriteLine("Successfully applied migrations!");
    Console.ResetColor();
}
