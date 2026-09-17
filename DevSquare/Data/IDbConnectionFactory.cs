using System.Data;

namespace DevSquare.Data;

public interface IDbConnectionFactory
{
    IDbConnection CreateConnection();
}