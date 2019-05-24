import java.sql.*;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.Hashtable;

public class Assignment3 extends JDBCSubmission {

  // TEST BLOCK START <-------------------------------------------------------------------

  // // JDBC driver name and database URL
  // // static final String JDBC_DRIVER = "org.postgresql.Driver";
  // static final String url = "jdbc:postgresql://localhost:5432/csc343h-xieruiyu";
  //
  // // Database credentials
  // static final String username = "xieruiyu";
  // static final String password = "mcnxshwdd";
  //
  // // Country name
  // static final String countryName = "Germany";
  //
  // // Similar party id
  // static final Integer partyID = 305;
  // static final Float threshold = (float) 0.25;

  // TEST BLOCK END <-------------------------------------------------------------------
  
  public Assignment3() throws ClassNotFoundException {
    // Register JDBC driver
    try {
      Class.forName("org.postgresql.Driver");
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
      System.out.println("Couldn't find Driver");
    }
  }

  @Override
  /**
   * Connect database
   * 
   * @param url: url of the server
   * @param username: name of the user
   * @param password: password of the user return boolean
   */
  public boolean connectDB(String url, String username, String password) {
    // write your code here.
    try {
      // Open a connection
      System.out.println("Connecting to database");
      connection = DriverManager.getConnection(url, username, password);
      System.out.println("Connection Success");
    } catch (SQLException e) {
      e.printStackTrace();
      System.out.println("Connection fail");
    } catch (Exception ex) {
      ex.printStackTrace();
      System.out.println("Connection fail");
    }
    return true;
  }

  @Override
  /**
   * Disconnect database
   * 
   * return boolean
   */
  public boolean disconnectDB() {
    // write your code here.
    try {
      // Close a connection
      System.out.println("Disconnecting from database");
      if (connection != null) {
        connection.close();
      }
      System.out.println("Disconnection Success");
    } catch (SQLException e) {
      e.printStackTrace();
      System.out.println("Disconnection fail");
    } catch (Exception ex) {
      ex.printStackTrace();
      System.out.println("Disconnection fail");
    }
    return true;
  }
  
  @Override
  /**
   * Given a country, returns the list of Presidents in that country, in descending order of date
   * of occupying the office, and the name of the party to which the president belonged.
   * 
   * @param countryName: name of the country
   * @return null
   */
  public ElectionResult presidentSequence(String countryName) {
    // Two list of presidentSequence
    List<Integer> presidentsList = new ArrayList<Integer>();
    List<String> partyNamesList = new ArrayList<String>();
    // Write the sql
    String sql;
    sql = "SELECT politician_president.id AS president, party.name AS party_name"
        + "FROM country JOIN politician_president ON country.id = politician_president.country_id"
        + "JOIN party ON politician_president.party_id = party.id"
        + "WHERE country.name = ?"
        + "ORDER BY politician_president.start_date DESC;";
    try {
      PreparedStatement execStat = connection.prepareStatement(sql);
      execStat.setString(1, countryName);
      ResultSet rs = execStat.executeQuery();
      while (rs.next()) {
        // Retrieve by column name
        int id = rs.getInt(1);
        String partyName = rs.getString(2);
        presidentsList.add(id);
        partyNamesList.add(partyName);
      }
    } catch (SQLException e) {
      e.printStackTrace();
      System.out.println("SQL Exception");
    } catch (Exception ex) {
      ex.printStackTrace();
      System.out.println("Other Exception");
    }
    return new ElectionResult(presidentsList, partyNamesList);
  }

  @Override
  /**
   * Given a party id, returns other parties that have similar descriptions in the database
   * 
   * @param partyId: the id of a party
   * @param threshold: a float point number that can be threshold
   * @return null
   */
  public List<Integer> findSimilarParties(Integer partyId, Float threshold) {
    // A hash table of findSimilarParties
    Map<Integer, Double> partyScore = new Hashtable<Integer, Double>();
    List<Integer> finalList = new ArrayList<Integer>();
    // Write the sql
    String sql;
    sql = "SELECT p2.id AS Party2_id,"
        + "p1.description AS P1_Des, p2.description AS P2_Des"
        + "FROM party p1, party p2"
        + "WHERE p1.id = ? AND p1.id != p2.id;";
    try {
      // from id find name find description
      PreparedStatement execStat = connection.prepareStatement(sql);
      execStat.setInt(1, partyId);
      ResultSet rs = execStat.executeQuery();
      while (rs.next()) {
        // Retrieve by column name
        Integer p2ID = rs.getInt("Party2_id");
        String p1Des = rs.getNString("P1_Des");
        String p2Des = rs.getNString("P2_Des");
        JDBCSubmission a3 = new Assignment3();
        Double score = a3.similarity(p1Des, p2Des);
        partyScore.put(p2ID, score);
      }
      // Manipulate score and find max (more than or equal to one)
      for (Object key : partyScore.keySet()) {
        Double temp = partyScore.get(key);
        if (temp >= threshold) {
          finalList.add((Integer) key);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
      System.out.println("SQL Exception");
    } catch (Exception ex) {
      ex.printStackTrace();
      System.out.println("Other Exception");
    }
    return finalList;
  }

  public static void main(String[] args) throws Exception {
    // Write code here.
    // TEST BLOCK START <-------------------------------------------------------------------

    // JDBCSubmission a3 = new Assignment3();
    // a3.connectDB(url, username, password);
    // a3.presidentSequence(countryName);
    // a3.findSimilarParties(partyID, threshold);
    // a3.disconnectDB();

    // TEST BLOCK END <---------------------------------------------------------------------
    System.out.println("Hellow World");
  }

}

