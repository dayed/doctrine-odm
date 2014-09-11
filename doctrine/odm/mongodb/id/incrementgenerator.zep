/*
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * This software consists of voluntary contributions made by many individuals
 * and is licensed under the MIT license. For more information, see
 * <http://www.doctrine-project.org>.
 */

namespace Doctrine\ODM\MongoDB\Id;

use Doctrine\ODM\MongoDB\DocumentManager;
use Doctrine\ODM\MongoDB\Mapping\ClassMetadata;

/**
 * IncrementGenerator is responsible for generating auto increment identifiers. It uses
 * a collection and generates the next id by using inc on a field named "current_id".
 *
 * The "collection" property determines which collection name is used to store the 
 * id values. If not specified it defaults to "doctrine_increment_ids".
 * 
 * The "key" property determines the document ID used to store the id values in the
 * collection. If not specified it defaults to the name of the collection for the 
 * document.
 *
 * @since       1.0
 * @author      Jonathan H. Wage <jonwage@gmail.com>
 */
class IncrementGenerator extends AbstractIdGenerator
{
    protected collection = null;
    protected key = null;
    
    public function setCollection(collection) 
    { 
        let this->collection = collection;
    }

    public function setKey(key) 
    { 
        let this->key = key;
    }
    
    /** @inheritDoc */
    public function generate( dm, document)
    {
        var className, db, coll, key, query, newObj, command, result;
        let className = get_class(document);
        let db = dm->getDocumentDatabase(className);
        
        let coll = this->collection ? "" : "doctrine_increment_ids";
        let key = this->key ? "" : dm->getDocumentCollection(className)->getName();
        
        let query = ["_id" : key];
        let newObj = ["inc" : ["current_id" : 1]];

        let command = [];
        let command["findandmodify"] = coll;
        let command["query"] = query;
        let command["update"] = newObj;
        let command["upsert"] = true;
        let command["new"] = true;
        let result = db->command(command);
        return result["value"]["current_id"];
    }
}