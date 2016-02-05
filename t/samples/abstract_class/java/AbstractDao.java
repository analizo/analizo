package br.usp.ime.ccsl.kalibro.database.daos;

import static br.usp.ime.ccsl.kalibro.core.utilities.ReflectionUtils.*;

import br.usp.ime.ccsl.kalibro.core.types.KalibroType;
import br.usp.ime.ccsl.kalibro.database.DatabaseConnector;

import java.awt.Color;
import java.lang.reflect.Method;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

/**
 * Parent class of all Kalibro data access objects. Contains utility data access methods.
 *
 * @author Carlos Morais
 */

public abstract class AbstractDao {

    protected DatabaseConnector connector;

    public AbstractDao() throws SQLException {
        this(new DatabaseConnector());
    }

    public AbstractDao(DatabaseConnector connector) {
        this.connector = connector;
    }

    /**
     * Returns the string quoted (with simple quotes).

     * A simple quote is also added before any simple quote present in the original string.

     * This method should be used for preventing SQL injection.
     *


     * Example: "Joana d'Arc" becomes "'Joana d''Arc'"
     */
    protected String quote(Object object) {
        if (new Double(Double.POSITIVE_INFINITY).equals(object))
            return "" + Double.MAX_VALUE;
        if (new Double(Double.NEGATIVE_INFINITY).equals(object))
            return "" + Double.MIN_VALUE;
        if (object instanceof Color)
            return "" + ((Color) object).getRGB();
        if (object instanceof Date)
            return "" + ((Date) object).getTime();
        return (object == null) ? "null" : "'" + object.toString().replaceAll("'", "''") + "'";
    }

    private String prepare(String skeleton, KalibroType object) {
        String result = skeleton;
        for (Method method : object.getClass().getMethods())
            result = result.replace("$" + method.getName(), quote(getValue(method.getName(), object)));
        return result;
    }

    /**
     * Replaces the occurrences of "$" + fieldName with the values of the field for the specified object. For
     * example, "name = $name" becomes "name = 'Sample'" if object.name = "Sample". For more than one object,
     * prepare(skeleton, object1, object2) id equivalent to
     * prepare(prepare(skeleton, object1), object2).
     */
    protected String prepare(String skeleton, KalibroType... objects) {
        String result = skeleton;
        for (KalibroType object : objects)
            result = prepare(result, object);
        return result;
    }

    /**
     * Does what ResultSet.getDouble() does, but when the field content is null, returns a null
     * Double object instead of 0.0
     */
    protected Double getDouble(ResultSet resultSet, String column) throws SQLException {
        double value = resultSet.getDouble(column);
        return resultSet.wasNull() ? null : value;
    }
}

