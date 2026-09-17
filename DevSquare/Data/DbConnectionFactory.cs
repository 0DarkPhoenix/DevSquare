using System.Data;
using Npgsql;

namespace DevSquare.Data;

public sealed class DbConnectionFactory(IConfiguration configuration)
    : IDbConnectionFactory
{
    public IDbConnection CreateConnection()
    {
        var connectionString =
            configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException(
                "The DefaultConnection connection string is missing.");

        return new NpgsqlConnection(connectionString);
    }
}