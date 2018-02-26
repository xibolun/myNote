判断NODE是否发生变化 

```
 /**
     * Creates a new node or updates an existing one in the graph, if it has changed.
     *
     * @param entity      the domain object to be persisted
     * @param context     the current {@link CompileContext}
     * @param nodeBuilder a {@link NodeBuilder} that knows how to compile node create/update cypher phrases
     */
    private void updateNode(Object entity, CompileContext context, NodeBuilder nodeBuilder) {
        // fire pre-save event here
        if (mappingContext.isDirty(entity)) {
            logger.debug("{} has changed", entity);
            context.register(entity);
            ClassInfo classInfo = metaData.classInfo(entity);
            Collection<PropertyReader> propertyReaders = EntityAccessManager.getPropertyReaders(classInfo);
            for (PropertyReader propertyReader : propertyReaders) {
                if (propertyReader.isComposite()) {
                    nodeBuilder.addProperties(propertyReader.readComposite(entity));
                } else {
                    nodeBuilder.addProperty(propertyReader.propertyName(), propertyReader.readProperty(entity));
                }
            }
        } else {
            context.deregister(nodeBuilder);
            logger.debug("{}, has not changed", entity);
        }

    }
```

